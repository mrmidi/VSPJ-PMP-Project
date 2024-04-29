//
//  CourseDetailedView.swift
//  MyVSPJ
//
//  Created by Alexander Shabelnikov on 28.04.2024.
//

import Foundation
import SwiftUI
import SwiftData
import Charts

struct CourseDetailedView: View {
    var course: Course
    @Environment(\.modelContext) private var modelContext
    @Query private var courseStats: [CourseCompletionStat]
    @State private var filteredCourseStats: [CourseCompletionStat] = []
    @State private var chartData: [ChartDataElement] = []
    @State private var statsPair: [ChartDataElement] = []
    @State private var chartGradeData: [ChartGradeDataElement] = []
    @Query private var courseDetails: [CourseDetail]
    @State private var filteredCourseDetails: CourseDetail?
    

    var body: some View {
          ScrollView {
              VStack(alignment: .leading, spacing: 20) {
                  Text("Course Statistics").font(.title)
                  
                  drawCompletionStat
                  
                  Spacer(minLength: 30)
                  
                  Text("Syllabus").font(.title)
                  syllabusView
                  
                  Text("Guarantor").font(.title)
                  Text(filteredCourseDetails?.guarantor ?? "Unknown")
                      .font(.body)
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.horizontal)
              }
              .padding(.horizontal)
          }
      }
    
    private var syllabusView: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(syllabusItems, id: \.self) { item in
                Text("• \(item)")
                    .font(.body)
                    .padding(.leading, 20)
            }
        }
        .padding()
    }

    // Helper to split syllabus into bullet points
    private var syllabusItems: [String] {
        filteredCourseDetails?.syllabus?.components(separatedBy: "\n") ?? ["Syllabus content not found"]
    }
    
    private func drawGradeChartForTerm(termIndex: Int) -> some View {
        let startIndex = termIndex * 5 // Start index for each term based on 5 grades per term
        let endIndex = min(startIndex + 5, chartGradeData.count) // Safeguard against out-of-bounds

        // Slice the array for just the grades related to the termIndex
        let termData = Array(chartGradeData[startIndex..<endIndex])

        return VStack {
            Text("Term \(termIndex + 1) Grades")
                .font(.headline)
            Chart {
                ForEach(termData, id: \.id) { gradeData in
                    BarMark(
                        x: .value("Grade", gradeData.label),
                        y: .value("Percentage", gradeData.value * 100) // Convert to percentage
                    )
                    .foregroundStyle(by: .value("Grade", gradeData.label))
                }
            }
            .chartYScale(domain: [0, 100]) // Set y-axis range to 0-100%
            .padding()
            .chartLegend {
                EmptyView()
            } // Center the legend horizontally at the bottom

        }
        .frame(height: 200) // Adjust height as needed
    }

    
    private var drawCompletionStat: some View {
        VStack {
            if chartData.isEmpty {
                Text("No data available")
            } else {
                // Use a separate function to build the charts for each term
                ForEach(0..<chartData.count/2, id: \.self) { termIndex in
                    drawChartForTerm(termIndex: termIndex)
                }
            }
            Spacer() // Provides spacing and ensures that VStack is the top-level container

            // Grades
            if !chartGradeData.isEmpty {
                VStack {
                    Text("Completion grades").font(.headline)
                    // Grade Charts
                    ForEach(0..<chartGradeData.count / 5) { termIndex in // Divide by 5 as each term has 5 grades
                        drawGradeChartForTerm(termIndex: termIndex)
                    }
                }
            } else {
                Text("No grades available for this course")
            }
        }
        .navigationTitle(course.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            filterStatsByCourse()
            prepareChartData()
            prepareGradeChartData()
            fetchCourseDetails()
        }
    }
    
    private func fetchCourseDetails() {
        filteredCourseDetails = courseDetails.filter { $0.courseId == course.courseId }.first
        print(filteredCourseDetails ?? "failed")
    }

    
    // Function to create the chart for a specific term
    private func drawChartForTerm(termIndex: Int) -> some View {
        let startIndex = termIndex * 2
        let termData = Array(chartData[startIndex..<startIndex+2]) // Get data for the term
        
        return VStack {
            Text("Term \(termIndex + 1)")
                .font(.headline)
            Chart(termData) { data in
                BarMark(
                    x: .value("Value", data.value)
                )
                .foregroundStyle(by: .value("Label", data.label)) // Color bars based on label
            }
            .chartLegend(position: .bottom, alignment: .center) // Center the legend horizontally at the bottom
            .padding()
        }.frame(height: 100)
    }
    
    private func filterStatsByCourse() {
        filteredCourseStats = courseStats.filter { $0.courseId == course.courseId }
        print("Total terms: \(filteredCourseStats.count)")
    }
    
    private func getPair(startFrom: Int) {
        // function will collect 2 elements from chartData and store them as a pair
        // reset statsPair
        statsPair = []
        if startFrom < chartData.count {
            statsPair = [chartData[startFrom], chartData[startFrom + 1]]
        }
    }
    
    private func prepareChartData() {
        // Flatten the filteredCourseStats into a single array of ChartDataElement using flatMap
        chartData = filteredCourseStats.flatMap { stat -> [ChartDataElement] in
            var elements: [ChartDataElement] = []
            if let term = stat.term, let totalAttended = stat.totalAttended {
                elements.append(ChartDataElement(label: "Attended", value: totalAttended))
            }
            if let term = stat.term, let totalCompleted = stat.totalCompleted {
                elements.append(ChartDataElement(label: "Completed", value: totalCompleted))
            }
            print("Resulting array: \(elements)")
            return elements
        }
    }
    
    private func prepareGradeChartData() {
        chartGradeData = filteredCourseStats.flatMap { stat -> [ChartGradeDataElement] in
            guard checkGradesIsNotNull(stat: stat) else { return [] } // Skip if all grades are null
            
            var elements: [ChartGradeDataElement] = []
            if let term = stat.term {
                elements.append(contentsOf: [
                    ChartGradeDataElement(label: "A", value: stat.gradeARate ?? 0),
                    ChartGradeDataElement(label: "B", value: stat.gradeBRate ?? 0),
                    ChartGradeDataElement(label: "C", value: stat.gradeCRate ?? 0),
                    ChartGradeDataElement(label: "D", value: stat.gradeDRate ?? 0),
                    ChartGradeDataElement(label: "E", value: stat.gradeERate ?? 0)
                ])
                print("Resulting GRADES array: \(elements)")
                return elements
            }
            return [] // Return empty array if term is nil
        }
    }
    
    
    private func checkGradesIsNotNull(stat: CourseCompletionStat) -> Bool {
        return stat.gradeARate != nil || stat.gradeBRate != nil ||
               stat.gradeCRate != nil || stat.gradeDRate != nil ||
               stat.gradeERate != nil
    }
}

struct ChartDataElement: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
}

struct ChartGradeDataElement: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

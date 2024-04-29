//
//  ContentView.swift
//  MyVSPJ
//
//  Created by Alexander Shabelnikov on 26.04.2024.
//

import SwiftUI
import SwiftData
import Charts


struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Course.semester), SortDescriptor(\Course.name)]) private var courses: [Course]
    @Query private var studyPlan: [StudyPlan]
    @State private var creditData: [CreditData] = []
    
    var body: some View {
        NavigationView {
            VStack {
                chartsGrid
                coursesList
            }
            .navigationTitle("Study Structure")
            .onAppear(perform: loadCredits)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { // or .navigationBarTrailing if you want the button on the right side
                    NavigationLink(destination: StudyPlanView()) {
                        Text("Study Plan")
                    }
                }
            }
        }
    }
    
    private var coursesList: some View {
        List {
            ForEach(courses, id: \.id) { course in
                NavigationLink(destination: CourseDetailedView(course: course)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(course.name)
                                .font(.headline)
                            Text("Credits: \(course.credits ?? 0)")
                                .font(.subheadline)
                            Text("Type: \(courseTypeDescription(typeId: course.typeId))")
                                .font(.caption)
                                .foregroundColor(courseTypeColor(typeId: course.typeId))
                        }
                        Spacer()
                        Image(systemName: course.isTaken ? "minus.circle.fill" : "plus.circle.fill")
                            .foregroundColor(course.isTaken ? .red : .green)
                            .frame(width: 44, height: 44)
                    }
                }
                .swipeActions {
                    Button(role: course.isTaken ? .destructive : .none) {
                        toggleCourse(course: course)
                    } label: {
                        Label(course.isTaken ? "Remove" : "Add", systemImage: course.isTaken ? "minus.circle.fill" : "plus.circle.fill")
                    }
                    .tint(course.isTaken ? .red : .green)
                }
            }
        }
    }

    
    private var chartsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(creditData.filter { $0.category != "Foreign Language" }) { data in
                creditChart(for: data)
            }
        }
    }
    
    private func creditChart(for data: CreditData) -> some View {
        let totalAngle = 360.0
        let takenAngle = min(Double(data.taken) / Double(data.required) * totalAngle, totalAngle)
        let excessAngle = (max(0.0, Double(data.taken) - Double(data.required)) / Double(data.required) * totalAngle)
//        let excessAngle = max(0.0, takenAngle - 1.0)
        let remainingAngle = totalAngle - takenAngle - excessAngle

        return VStack {
            
            Text(data.category)
                .font(.caption)
                .foregroundColor(data.color)
                .padding(.bottom, 4)
                
            
            Chart {
                
                // Display the portion of required credits that have been taken
                SectorMark(
                    angle: .value("Taken", takenAngle),
                    innerRadius: .ratio(0.618),
                    outerRadius: .inset(10),
                    angularInset: 1
                )
                .foregroundStyle(data.color)

                // Display the excess credits in pink
//                if data.taken > data.required {
//                    SectorMark(
//                        angle: .value("Excess", excessAngle),
//                        innerRadius: .ratio(0.618),
//                        outerRadius: .inset(10),
//                        angularInset: 1
//                    )
//                    .foregroundStyle(Color.pink)
//                }

                // Display the remaining required credits as a muted segment
                SectorMark(
                    angle: .value("Remaining", remainingAngle),
                    innerRadius: .ratio(0.618),
                    outerRadius: .inset(10),
                    angularInset: 1
                )
                .foregroundStyle(Color.gray.opacity(0.5)) // Muted color for the remaining part
            }
            .frame(height: 100) // Fixed height for each chart

            // Add a legend and description below the chart
            Text("\(data.taken)/\(data.required) Credits Taken")
                .font(.caption)
                .foregroundColor(data.color)
                .padding(.top, 4)

            // Only display excess description if there are excess credits
            if data.taken > data.required {
                Text("Excess: \(data.taken - data.required) Credits")
                    .font(.caption)
                    .foregroundColor(Color.pink)
                    .padding(.top, 2)
            }
        }
    }




    private func electiveACredits() -> Int {
        let electiveACredits = courses.filter { $0.typeId == 3 && $0.isTaken == true }.reduce(0) { (sum, course) in
            sum + (course.credits ?? 0)
        }
        // print("Elective A credits taken: \(electiveACredits)")
        return electiveACredits
    }

    private func electiveBCredits() -> Int {
        let electiveBCredits = courses.filter { $0.typeId == 4 && $0.isTaken }.reduce(0) { (sum, course) in
            sum + (course.credits ?? 0)
        }
        return electiveBCredits
    }

    private func foreignLanguageCredits() -> Int {
        let foreignLanguageCredits = courses.filter { $0.typeId == 2 && $0.isTaken }.reduce(0) { (sum, course) in
            sum + (course.credits ?? 0)
        }
        return foreignLanguageCredits
    }

    private func optionalCredits() -> Int {
        let optionalCredits = courses.filter { $0.typeId == 5 && $0.isTaken == true}.reduce(0) { (sum, course) in
            sum + (course.credits ?? 0)
        }
        // print("Optional credits taken: \(optionalCredits)")
        return optionalCredits
    }

    private func totalCredits() -> Int {
        // filter all taken courses
        let takenCoursesCredits = courses.filter { $0.isTaken == true }.reduce(0) { (sum, course) in
            sum + (course.credits ?? 0)
        }
        return takenCoursesCredits
    }
    
    private func calcOverDue(taken: Int, required: Int) -> Int {
        let excess = taken - required
        return excess > 0 ? excess : 0
    }

    private func toggleCourse(course: Course) {
        // print("Credits: \(totalCredits())")
        course.isTaken.toggle()
        loadCredits()

        // You may need to explicitly save the context if these changes need to be persisted
        // try? modelContext.save()
    }


    
    
    private func isTaken(course: Course) -> Bool {
        // print("Checking if course is taken: \(course.name)")
        var taken = false
        taken = studyPlan.contains(where: { $0.course.id == course.id })
        // print("Course is taken: \(taken)")
        return taken
    }
    
    private func addCourse(course: Course) {
        // print("Adding course to study plan: \(course.name)")
        let newStudyPlanItem = StudyPlan(course: course)
        modelContext.insert(newStudyPlanItem)
    }
    
    private func removeCourse(course: Course) {
        // print("Removing course from study plan: \(course.name)")
        if isTaken(course: course) {
            modelContext.delete(studyPlan.first(where: { $0.course.id == course.id })!)
        }
    }
    
    private func courseTypeDescription(typeId: Int) -> String {
        switch typeId {
        case 1:
            return "Mandatory"
        case 2:
            return "Foreign Language"
        case 3:
            return "Elective A"
        case 4:
            return "Elective B"
        case 5:
            return "Optional Subject"
        default:
            return "Unknown Type"
        }
    }
    
    private func courseTypeColor(typeId: Int) -> Color {
        switch typeId {
        case 1:
            return Color.red
        case 2:
            return Color.red
        case 3:
            return Color.cyan
        case 4:
            return Color.green
        case 5:
            return Color.blue
        default:
            return Color.teal
        }
    }

    

    private func loadCredits() {
        let electiveACreditsTaken = electiveACredits()
        let electiveBCreditsTaken = electiveBCredits()
        let optionalCreditsTaken = optionalCredits()
        let totalCreditsTaken = totalCredits()

        creditData = [
            CreditData(category: "Elective A", taken: electiveACreditsTaken, required: 32, color: Color.cyan, overDue: calcOverDue(taken: electiveACreditsTaken, required: 32)),
            CreditData(category: "Elective B", taken: electiveBCreditsTaken, required: 12, color: Color.green, overDue: calcOverDue(taken: electiveBCreditsTaken, required: 12)),
            CreditData(category: "Optional", taken: optionalCreditsTaken, required: 15, color: Color.blue, overDue: calcOverDue(taken: optionalCreditsTaken, required: 15)),
            CreditData(category: "Total", taken: totalCreditsTaken, required: 180, color: Color.red, overDue: calcOverDue(taken: totalCreditsTaken, required: 180))
        ]
    }
    
    
    struct CreditData: Identifiable {
        var id = UUID()
        
        let category: String
        let taken: Int
        let required: Int
        let color: Color
        let overDue: Int
    }

    
}



#Preview {
    MainView()
        .modelContainer(for: Course.self, inMemory: true)
}

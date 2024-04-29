//
//  StudyPlanView.swift
//  MyVSPJ
//
//  Created by Alexander Shabelnikov on 29.04.2024.
//

import SwiftUI
import SwiftData

struct StudyPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCourses: [Course]

    var body: some View {
        ScrollView {
            VStack {
                ForEach(1...6, id: \.self) { semester in
                    SemesterBlock(semester: semester, courses: filteredCourses(for: semester))
                }
            }
        }
    }
    
    private func filteredCourses(for semester: Int) -> [Course] {
        allCourses.filter { $0.semester == semester && $0.isTaken }
    }
    

}

struct SemesterBlock: View {
    let semester: Int
    var courses: [Course]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Semester \(semester)").font(.headline)
            ForEach(courses, id: \.courseId) { course in
                CourseRow(course: course)
            }
            TotalCreditsView(courses: courses)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct CourseRow: View {
    var course: Course
    
    var body: some View {
        HStack {
            Text(course.name)
            Spacer()
            Text("\(course.credits ?? 0) credits")
            Text(getType(typeId: course.typeId))
            Text(getCompletion(completionId: course.completionId))
        }
    }
    
    
    private func getType(typeId: Int) -> String {
        switch typeId {
        case 1: return "P"
        case 2: return "CJ"
        case 3: return "PV A"
        case 4: return "PV B"
        case 5: return "V"
        default:
            assertionFailure("Unknown typeId: \(typeId)")
            return "Unknown"
        }
    }

    private func getCompletion(completionId: Int) -> String {
        switch completionId {
        case 1: return "ZA"
        case 2: return "KZ"
        case 3: return "ZK"
        case 4: return "Z,ZK"
        default:
            assertionFailure("Unknown completionId: \(completionId)")
            return "Unknown"
        }
    }
}



struct TotalCreditsView: View {
    var courses: [Course]
    
    var body: some View {
        HStack {
            Spacer()
            Text("Total Credits: \(totalCredits())")
                .bold()
        }
    }
    
    private func totalCredits() -> Int {
        courses.reduce(0) { $0 + ($1.credits ?? 0) }
    }
}


#Preview {
    StudyPlanView()
}

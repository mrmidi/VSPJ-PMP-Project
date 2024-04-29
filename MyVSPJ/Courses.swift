//
//  Courses.swift
//  MyVSPJ
//
//  Created by Alexander Shabelnikov on 27.04.2024.
//

import Foundation
import SwiftData

import SwiftUI

@Model
final class CompletionType: Decodable, Identifiable {
    var completionId: Int
    var completionCode: String
    private var desc: String? // Changed property name to avoid conflict with 'description'

    enum CodingKeys: String, CodingKey {
        case id = "completion_id"
        case completionCode = "completion_code"
        case desc = "description"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        completionId = try container.decode(Int.self, forKey: .id)
        completionCode = try container.decode(String.self, forKey: .completionCode)
        desc = try container.decodeIfPresent(String.self, forKey: .desc)
    }
   
    // Since 'description' is reserved, use another property or function to access it
    var description: String? {
        return desc
    }
}

@Model
final class CourseType: Decodable, Identifiable {
    var courseTypeId: Int
    var typeCode: String
    private var desc: String? // Using a private variable to avoid conflict with 'description'

    enum CodingKeys: String, CodingKey {
        case id = "type_id"
        case typeCode = "type_code"
        case desc = "description"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        courseTypeId = try container.decode(Int.self, forKey: .id)
        typeCode = try container.decode(String.self, forKey: .typeCode)
        desc = try container.decodeIfPresent(String.self, forKey: .desc)
    }
    
    // Providing access to 'description' through a computed property
    var description: String? {
        get { return desc }
        set { desc = newValue }
    }
}

@Model
final class Department: Decodable, Identifiable {
    var departmentId: Int
    var departmentCode: String
    var departmentName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "department_id"
        case departmentCode = "department_code"
        case departmentName = "department_name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        departmentId = try container.decode(Int.self, forKey: .id)
        departmentCode = try container.decode(String.self, forKey: .departmentCode)
        departmentName = try container.decode(String.self, forKey: .departmentName)
    }
}

@Model
final class TestModel {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}


@Model
final class Course: Decodable, Identifiable {
    var courseId: String
    var name: String
    var abbreviation: String?
    var typeId: Int
    var teachingMethod: String?
    var semester: Int?
    var weeklyLectures: Int?
    var weeklyExercises: Int?
    var credits: Int?
    var completionId: Int
    var departmentId: Int
    var isTaken: Bool
    var semesterTaken: Int
    
    enum CodingKeys: String, CodingKey {
        case courseId = "course_id"
        case name
        case abbreviation
        case typeId = "type_id"
        case teachingMethod = "teaching_method"
        case semester
        case weeklyLectures = "weekly_lectures"
        case weeklyExercises = "weekly_exercises"
        case credits
        case completionId = "completion_id"
        case departmentId = "department_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        courseId = try container.decode(String.self, forKey: .courseId)
        name = try container.decode(String.self, forKey: .name)
        abbreviation = try container.decodeIfPresent(String.self, forKey: .abbreviation)
        typeId = try container.decode(Int.self, forKey: .typeId)
        teachingMethod = try container.decodeIfPresent(String.self, forKey: .teachingMethod)
        semester = try container.decodeIfPresent(Int.self, forKey: .semester)
        weeklyLectures = try container.decodeIfPresent(Int.self, forKey: .weeklyLectures)
        weeklyExercises = try container.decodeIfPresent(Int.self, forKey: .weeklyExercises)
        credits = try container.decodeIfPresent(Int.self, forKey: .credits)
        completionId = try container.decode(Int.self, forKey: .completionId)
        departmentId = try container.decode(Int.self, forKey: .departmentId)
        isTaken = false
        semesterTaken = 0        

    }
}

@Model
final class CourseCompletionStat: Decodable, Identifiable {
    var statId: Int
    var courseId: String
    var term: Int?
    var totalAttended: Int?
    var totalCompleted: Int?
    var completedWithCredit: Int?
    var completedWithExam: Int?
    var gradeARate: Double?
    var gradeBRate: Double?
    var gradeCRate: Double?
    var gradeDRate: Double?
    var gradeERate: Double?
    
    enum CodingKeys: String, CodingKey {
        case statId = "stats_id"
        case courseId = "course_id"
        case term
        case totalAttended = "total_attended"
        case totalCompleted = "total_completed"
        case completedWithCredit = "completed_with_credit"
        case completedWithExam = "completed_with_exam"
        case gradeARate = "grade_a_rate"
        case gradeBRate = "grade_b_rate"
        case gradeCRate = "grade_c_rate"
        case gradeDRate = "grade_d_rate"
        case gradeERate = "grade_e_rate"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statId = try container.decode(Int.self, forKey: .statId)
        courseId = try container.decode(String.self, forKey: .courseId)
        term = try container.decodeIfPresent(Int.self, forKey: .term)
        totalAttended = try container.decodeIfPresent(Int.self, forKey: .totalAttended)
        totalCompleted = try container.decodeIfPresent(Int.self, forKey: .totalCompleted)
        completedWithCredit = try container.decodeIfPresent(Int.self, forKey: .completedWithCredit)
        completedWithExam = try container.decodeIfPresent(Int.self, forKey: .completedWithExam)
        gradeARate = try container.decodeIfPresent(Double.self, forKey: .gradeARate)
        gradeBRate = try container.decodeIfPresent(Double.self, forKey: .gradeBRate)
        gradeCRate = try container.decodeIfPresent(Double.self, forKey: .gradeCRate)
        gradeDRate = try container.decodeIfPresent(Double.self, forKey: .gradeDRate)
        gradeERate = try container.decodeIfPresent(Double.self, forKey: .gradeERate)
    }
}

@Model
final class CourseDetail: Decodable, Identifiable {
    var detailId: Int
    var courseId: String
    var syllabus: String?
    var literature: String?
    var annotation: String?
    var guarantor: String?
    var credits: Int?
    
    enum CodingKeys: String, CodingKey {
        case detailId = "detail_id"
        case courseId = "course_id"
        case syllabus
        case literature
        case annotation
        case guarantor
        case credits
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        detailId = try container.decode(Int.self, forKey: .detailId)
        courseId = try container.decode(String.self, forKey: .courseId)
        syllabus = try container.decodeIfPresent(String.self, forKey: .syllabus)
        literature = try container.decodeIfPresent(String.self, forKey: .literature)
        annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        guarantor = try container.decodeIfPresent(String.self, forKey: .guarantor)
        credits = try container.decodeIfPresent(Int.self, forKey: .credits)

    }

}

// Model to represent a study plan
@Model
final class StudyPlan: Identifiable {
    var course: Course
    
    init(course: Course) {
        self.course = course
    }   
}

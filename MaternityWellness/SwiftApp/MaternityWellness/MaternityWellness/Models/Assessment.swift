import Foundation

// Enum for assessment types
enum AssessmentType: String, Codable, CaseIterable {
    case epds = "Edinburgh Postnatal Depression Scale"
    case phq9 = "Patient Health Questionnaire-9"
    
    var abbreviation: String {
        switch self {
        case .epds: return "EPDS"
        case .phq9: return "PHQ-9"
        }
    }
    
    var description: String {
        switch self {
        case .epds:
            return "A 10-question screening tool used to identify mothers at risk for perinatal depression."
        case .phq9:
            return "A 9-question instrument used to screen, diagnose, monitor and measure severity of depression."
        }
    }
}

// Struct for questions
struct AssessmentQuestion: Identifiable, Codable {
    var id: Int
    var text: String
    var options: [String]
    var scores: [Int] // corresponds to each option
}

// Struct for storing assessment results
struct AssessmentResult: Identifiable, Codable {
    var id: String
    var userId: String
    var type: AssessmentType
    var date: Date
    var score: Int
    var answers: [Int: Int] // question ID to score mapping
    
    var interpretation: String {
        switch type {
        case .epds:
            if score >= 0 && score <= 8 {
                return "Low risk"
            } else if score >= 9 && score <= 12 {
                return "Medium risk"
            } else {
                return "High risk"
            }
        case .phq9:
            if score >= 0 && score <= 4 {
                return "Minimal depression"
            } else if score >= 5 && score <= 9 {
                return "Mild depression"
            } else if score >= 10 && score <= 14 {
                return "Moderate depression"
            } else if score >= 15 && score <= 19 {
                return "Moderately severe depression"
            } else {
                return "Severe depression"
            }
        }
    }
    
    var color: Color {
        switch type {
        case .epds:
            if score >= 0 && score <= 8 {
                return Color("GoodMood")
            } else if score >= 9 && score <= 12 {
                return Color("OkayMood")
            } else {
                return Color("TerribleMood")
            }
        case .phq9:
            if score >= 0 && score <= 4 {
                return Color("GreatMood")
            } else if score >= 5 && score <= 9 {
                return Color("GoodMood")
            } else if score >= 10 && score <= 14 {
                return Color("OkayMood")
            } else if score >= 15 && score <= 19 {
                return Color("SadMood")
            } else {
                return Color("TerribleMood")
            }
        }
    }
    
    init(id: String = UUID().uuidString, userId: String, type: AssessmentType, date: Date = Date(), score: Int, answers: [Int: Int]) {
        self.id = id
        self.userId = userId
        self.type = type
        self.date = date
        self.score = score
        self.answers = answers
    }
}

// EPDS Questions
let epdsQuestions: [AssessmentQuestion] = [
    AssessmentQuestion(
        id: 1,
        text: "I have been able to laugh and see the funny side of things",
        options: [
            "As much as I always could",
            "Not quite so much now",
            "Definitely not so much now",
            "Not at all"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 2,
        text: "I have looked forward with enjoyment to things",
        options: [
            "As much as I ever did",
            "Rather less than I used to",
            "Definitely less than I used to",
            "Hardly at all"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 3,
        text: "I have blamed myself unnecessarily when things went wrong",
        options: [
            "No, never",
            "Not very often",
            "Yes, some of the time",
            "Yes, most of the time"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 4,
        text: "I have been anxious or worried for no good reason",
        options: [
            "No, not at all",
            "Hardly ever",
            "Yes, sometimes",
            "Yes, very often"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 5,
        text: "I have felt scared or panicky for no very good reason",
        options: [
            "No, not at all",
            "No, not much",
            "Yes, sometimes",
            "Yes, quite a lot"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 6,
        text: "Things have been getting on top of me",
        options: [
            "No, I have been coping as well as ever",
            "No, most of the time I have coped quite well",
            "Yes, sometimes I haven't been coping as well as usual",
            "Yes, most of the time I haven't been able to cope at all"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 7,
        text: "I have been so unhappy that I have had difficulty sleeping",
        options: [
            "No, not at all",
            "Not very often",
            "Yes, sometimes",
            "Yes, most of the time"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 8,
        text: "I have felt sad or miserable",
        options: [
            "No, not at all",
            "Not very often",
            "Yes, quite often",
            "Yes, most of the time"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 9,
        text: "I have been so unhappy that I have been crying",
        options: [
            "No, never",
            "Only occasionally",
            "Yes, quite often",
            "Yes, most of the time"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 10,
        text: "The thought of harming myself has occurred to me",
        options: [
            "Never",
            "Hardly ever",
            "Sometimes",
            "Yes, quite often"
        ],
        scores: [0, 1, 2, 3]
    )
]

// PHQ-9 Questions
let phq9Questions: [AssessmentQuestion] = [
    AssessmentQuestion(
        id: 1,
        text: "Little interest or pleasure in doing things",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 2,
        text: "Feeling down, depressed, or hopeless",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 3,
        text: "Trouble falling or staying asleep, or sleeping too much",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 4,
        text: "Feeling tired or having little energy",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 5,
        text: "Poor appetite or overeating",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 6,
        text: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 7,
        text: "Trouble concentrating on things, such as reading the newspaper or watching television",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 8,
        text: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    ),
    AssessmentQuestion(
        id: 9,
        text: "Thoughts that you would be better off dead or of hurting yourself in some way",
        options: [
            "Not at all",
            "Several days",
            "More than half the days",
            "Nearly every day"
        ],
        scores: [0, 1, 2, 3]
    )
]
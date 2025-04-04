import SwiftUI

enum QuestionnaireType: String, CaseIterable, Codable {
    case epds = "Edinburgh Postnatal Depression Scale"
    case phq9 = "Patient Health Questionnaire-9"
    
    var description: String {
        switch self {
        case .epds:
            return "A 10-item questionnaire designed to identify women experiencing postnatal depression"
        case .phq9:
            return "A 9-item questionnaire used to identify and measure depression severity"
        }
    }
}

struct AssessmentQuestion: Identifiable {
    let id: Int
    let text: String
    let options: [AssessmentOption]
}

struct AssessmentOption {
    let value: Int
    let text: String
}

struct AssessmentResult: Identifiable, Codable {
    let id: Int
    let userId: Int
    let type: String
    let score: Int
    let date: Date
    let answers: [Int]
    
    var interpretation: String {
        if type == QuestionnaireType.epds.rawValue {
            switch score {
            case 0...8:
                return "Low risk"
            case 9...12:
                return "Possible depression"
            default:
                return "Probable depression"
            }
        } else {
            switch score {
            case 0...4:
                return "Minimal depression"
            case 5...9:
                return "Mild depression"
            case 10...14:
                return "Moderate depression"
            case 15...19:
                return "Moderately severe depression"
            default:
                return "Severe depression"
            }
        }
    }
    
    var severityColor: String {
        if type == QuestionnaireType.epds.rawValue {
            switch score {
            case 0...8:
                return "GreatMood"
            case 9...12:
                return "OkayMood"
            default:
                return "TerribleMood"
            }
        } else {
            switch score {
            case 0...4:
                return "GreatMood"
            case 5...9:
                return "GoodMood"
            case 10...14:
                return "OkayMood"
            case 15...19:
                return "SadMood"
            default:
                return "TerribleMood"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case score
        case date
        case answers
    }
}

class AssessmentViewModel: ObservableObject {
    @Published var questionnaire: QuestionnaireType = .epds
    @Published var questions: [AssessmentQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: [Int] = []
    @Published var assessmentResults: [AssessmentResult] = []
    @Published var isLoading: Bool = false
    @Published var isCompleted: Bool = false
    @Published var errorMessage: String? = nil
    
    func startAssessment(type: QuestionnaireType) {
        questionnaire = type
        questions = getQuestions(for: type)
        currentQuestionIndex = 0
        selectedAnswers = Array(repeating: -1, count: questions.count)
        isCompleted = false
    }
    
    func answerQuestion(at index: Int, with value: Int) {
        if index >= 0 && index < selectedAnswers.count {
            selectedAnswers[index] = value
        }
    }
    
    func getCurrentQuestion() -> AssessmentQuestion {
        if currentQuestionIndex < questions.count {
            return questions[currentQuestionIndex]
        } else {
            // Default empty question as a fallback
            return AssessmentQuestion(id: 0, text: "Error: No question available", options: [])
        }
    }
    
    func completeAssessment() {
        isLoading = true
        
        // Calculate score
        let score = selectedAnswers.reduce(0, +)
        
        // In a real app, this would be an API call to save the assessment result
        // For demo purposes, we'll just update local state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let newId = (self.assessmentResults.map { $0.id }.max() ?? 0) + 1
            
            let result = AssessmentResult(
                id: newId,
                userId: 1, // Hardcoded for demo
                type: self.questionnaire.rawValue,
                score: score,
                date: Date(),
                answers: self.selectedAnswers
            )
            
            self.assessmentResults.insert(result, at: 0) // Add to beginning
            self.isLoading = false
            self.isCompleted = true
        }
    }
    
    func cancelAssessment() {
        questions = []
        selectedAnswers = []
        currentQuestionIndex = 0
    }
    
    func loadPreviousAssessments() {
        isLoading = true
        
        // In a real app, this would be an API call
        // For demo purposes, we'll load sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.assessmentResults = self.getSampleResults()
            self.isLoading = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func getQuestions(for type: QuestionnaireType) -> [AssessmentQuestion] {
        switch type {
        case .epds:
            return getEPDSQuestions()
        case .phq9:
            return getPHQ9Questions()
        }
    }
    
    private func getEPDSQuestions() -> [AssessmentQuestion] {
        return [
            AssessmentQuestion(
                id: 1,
                text: "I have been able to laugh and see the funny side of things",
                options: [
                    AssessmentOption(value: 0, text: "As much as I always could"),
                    AssessmentOption(value: 1, text: "Not quite so much now"),
                    AssessmentOption(value: 2, text: "Definitely not so much now"),
                    AssessmentOption(value: 3, text: "Not at all")
                ]
            ),
            AssessmentQuestion(
                id: 2,
                text: "I have looked forward with enjoyment to things",
                options: [
                    AssessmentOption(value: 0, text: "As much as I ever did"),
                    AssessmentOption(value: 1, text: "Rather less than I used to"),
                    AssessmentOption(value: 2, text: "Definitely less than I used to"),
                    AssessmentOption(value: 3, text: "Hardly at all")
                ]
            ),
            AssessmentQuestion(
                id: 3,
                text: "I have blamed myself unnecessarily when things went wrong",
                options: [
                    AssessmentOption(value: 3, text: "Yes, most of the time"),
                    AssessmentOption(value: 2, text: "Yes, some of the time"),
                    AssessmentOption(value: 1, text: "Not very often"),
                    AssessmentOption(value: 0, text: "No, never")
                ]
            ),
            AssessmentQuestion(
                id: 4,
                text: "I have been anxious or worried for no good reason",
                options: [
                    AssessmentOption(value: 0, text: "No, not at all"),
                    AssessmentOption(value: 1, text: "Hardly ever"),
                    AssessmentOption(value: 2, text: "Yes, sometimes"),
                    AssessmentOption(value: 3, text: "Yes, very often")
                ]
            ),
            AssessmentQuestion(
                id: 5,
                text: "I have felt scared or panicky for no very good reason",
                options: [
                    AssessmentOption(value: 3, text: "Yes, quite a lot"),
                    AssessmentOption(value: 2, text: "Yes, sometimes"),
                    AssessmentOption(value: 1, text: "No, not much"),
                    AssessmentOption(value: 0, text: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 6,
                text: "Things have been getting on top of me",
                options: [
                    AssessmentOption(value: 3, text: "Yes, most of the time I haven't been able to cope at all"),
                    AssessmentOption(value: 2, text: "Yes, sometimes I haven't been coping as well as usual"),
                    AssessmentOption(value: 1, text: "No, most of the time I have coped quite well"),
                    AssessmentOption(value: 0, text: "No, I have been coping as well as ever")
                ]
            ),
            AssessmentQuestion(
                id: 7,
                text: "I have been so unhappy that I have had difficulty sleeping",
                options: [
                    AssessmentOption(value: 3, text: "Yes, most of the time"),
                    AssessmentOption(value: 2, text: "Yes, sometimes"),
                    AssessmentOption(value: 1, text: "Not very often"),
                    AssessmentOption(value: 0, text: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 8,
                text: "I have felt sad or miserable",
                options: [
                    AssessmentOption(value: 3, text: "Yes, most of the time"),
                    AssessmentOption(value: 2, text: "Yes, quite often"),
                    AssessmentOption(value: 1, text: "Not very often"),
                    AssessmentOption(value: 0, text: "No, not at all")
                ]
            ),
            AssessmentQuestion(
                id: 9,
                text: "I have been so unhappy that I have been crying",
                options: [
                    AssessmentOption(value: 3, text: "Yes, most of the time"),
                    AssessmentOption(value: 2, text: "Yes, quite often"),
                    AssessmentOption(value: 1, text: "Only occasionally"),
                    AssessmentOption(value: 0, text: "No, never")
                ]
            ),
            AssessmentQuestion(
                id: 10,
                text: "The thought of harming myself has occurred to me",
                options: [
                    AssessmentOption(value: 3, text: "Yes, quite often"),
                    AssessmentOption(value: 2, text: "Sometimes"),
                    AssessmentOption(value: 1, text: "Hardly ever"),
                    AssessmentOption(value: 0, text: "Never")
                ]
            )
        ]
    }
    
    private func getPHQ9Questions() -> [AssessmentQuestion] {
        return [
            AssessmentQuestion(
                id: 1,
                text: "Little interest or pleasure in doing things",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 2,
                text: "Feeling down, depressed, or hopeless",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 3,
                text: "Trouble falling or staying asleep, or sleeping too much",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 4,
                text: "Feeling tired or having little energy",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 5,
                text: "Poor appetite or overeating",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 6,
                text: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 7,
                text: "Trouble concentrating on things, such as reading the newspaper or watching television",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 8,
                text: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            ),
            AssessmentQuestion(
                id: 9,
                text: "Thoughts that you would be better off dead or of hurting yourself in some way",
                options: [
                    AssessmentOption(value: 0, text: "Not at all"),
                    AssessmentOption(value: 1, text: "Several days"),
                    AssessmentOption(value: 2, text: "More than half the days"),
                    AssessmentOption(value: 3, text: "Nearly every day")
                ]
            )
        ]
    }
    
    // Sample assessment results for demonstration purposes
    private func getSampleResults() -> [AssessmentResult] {
        let calendar = Calendar.current
        let today = Date()
        
        var results: [AssessmentResult] = []
        
        // EPDS result from 2 weeks ago
        if let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today) {
            results.append(
                AssessmentResult(
                    id: 1,
                    userId: 1,
                    type: QuestionnaireType.epds.rawValue,
                    score: 11, // Possible depression
                    date: twoWeeksAgo,
                    answers: [1, 1, 2, 1, 1, 1, 2, 1, 1, 0]
                )
            )
        }
        
        // EPDS result from 1 week ago
        if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) {
            results.append(
                AssessmentResult(
                    id: 2,
                    userId: 1,
                    type: QuestionnaireType.epds.rawValue,
                    score: 8, // Low risk
                    date: oneWeekAgo,
                    answers: [1, 1, 1, 1, 1, 1, 1, 0, 1, 0]
                )
            )
        }
        
        // PHQ-9 result from 3 days ago
        if let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today) {
            results.append(
                AssessmentResult(
                    id: 3,
                    userId: 1,
                    type: QuestionnaireType.phq9.rawValue,
                    score: 7, // Mild depression
                    date: threeDaysAgo,
                    answers: [1, 1, 1, 1, 1, 0, 1, 1, 0]
                )
            )
        }
        
        return results
    }
}
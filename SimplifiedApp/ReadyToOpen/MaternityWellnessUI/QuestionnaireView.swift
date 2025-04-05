import SwiftUI

enum QuestionnaireType {
    case epds
    case phq9
    
    var title: String {
        switch self {
        case .epds:
            return "Edinburgh Postnatal Depression Scale"
        case .phq9:
            return "Patient Health Questionnaire (PHQ-9)"
        }
    }
    
    var questions: [String] {
        switch self {
        case .epds:
            return EPDSQuestions
        case .phq9:
            return PHQ9Questions
        }
    }
    
    var options: [String] {
        switch self {
        case .epds:
            return ["0 - Not at all", "1 - Not very often", "2 - Yes, sometimes", "3 - Yes, most of the time"]
        case .phq9:
            return ["0 - Not at all", "1 - Several days", "2 - More than half the days", "3 - Nearly every day"]
        }
    }
}

// Edinburgh Postnatal Depression Scale (EPDS) Questions
let EPDSQuestions = [
    "I have been able to laugh and see the funny side of things",
    "I have looked forward with enjoyment to things",
    "I have blamed myself unnecessarily when things went wrong",
    "I have been anxious or worried for no good reason",
    "I have felt scared or panicky for no very good reason",
    "Things have been getting on top of me",
    "I have been so unhappy that I have had difficulty sleeping",
    "I have felt sad or miserable",
    "I have been so unhappy that I have been crying",
    "The thought of harming myself has occurred to me"
]

// Patient Health Questionnaire-9 (PHQ-9) Questions
let PHQ9Questions = [
    "Little interest or pleasure in doing things",
    "Feeling down, depressed, or hopeless",
    "Trouble falling or staying asleep, or sleeping too much",
    "Feeling tired or having little energy",
    "Poor appetite or overeating",
    "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
    "Trouble concentrating on things, such as reading the newspaper or watching television",
    "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
    "Thoughts that you would be better off dead or of hurting yourself in some way"
]

struct QuestionnaireView: View {
    let questionnaireType: QuestionnaireType
    @State private var currentQuestion = 0
    @State private var answers: [Int] = Array(repeating: -1, count: 10)
    @State private var isCompleted = false
    
    var progress: CGFloat {
        CGFloat(currentQuestion) / CGFloat(questionnaireType.questions.count)
    }
    
    var totalScore: Int {
        answers.reduce(0, +)
    }
    
    var body: some View {
        ZStack {
            ColorTheme.backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            if isCompleted {
                // Results view
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        VStack(alignment: .center, spacing: 15) {
                            Text("Assessment Complete")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ColorTheme.textGray)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                            
                            Text("Your \(questionnaireType.title) Score")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textGray)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                                    .frame(width: 150, height: 150)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(totalScore) / (questionnaireType.type == .epds ? 30.0 : 27.0))
                                    .stroke(scoreColor, lineWidth: 15)
                                    .frame(width: 150, height: 150)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut, value: totalScore)
                                
                                Text("\(totalScore)")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(scoreColor)
                            }
                            .padding(.vertical)
                            
                            Text(interpretationText)
                                .font(.headline)
                                .foregroundColor(scoreColor)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(scoreColor.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Recommendations
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recommendations")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textGray)
                            
                            ForEach(recommendations, id: \.self) { recommendation in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(ColorTheme.primaryPink)
                                        .padding(.top, 3)
                                    
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .foregroundColor(ColorTheme.textGray)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 5)
                            }
                            
                            if totalScore >= 10 {
                                Text("Note: This assessment is not a diagnosis. Please consult a healthcare professional for a proper evaluation.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Buttons
                        HStack {
                            Button(action: {
                                // Reset assessment
                                currentQuestion = 0
                                answers = Array(repeating: -1, count: 10)
                                isCompleted = false
                            }) {
                                Text("Retake Assessment")
                                    .fontWeight(.medium)
                                    .foregroundColor(ColorTheme.textGray)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                            }
                            
                            NavigationLink(destination: ResourcesView()) {
                                Text("View Resources")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(ColorTheme.buttonGradient)
                                    .cornerRadius(15)
                                    .shadow(color: ColorTheme.primaryPink.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top)
                }
            } else {
                // Question view
                VStack(spacing: 20) {
                    // Progress bar
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 10)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .cornerRadius(5)
                        
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width * progress, height: 10)
                            .foregroundColor(ColorTheme.primaryPink)
                            .cornerRadius(5)
                            .animation(.easeInOut, value: progress)
                    }
                    .padding(.horizontal)
                    
                    // Question number
                    Text("Question \(currentQuestion + 1) of \(questionnaireType.questions.count)")
                        .font(.headline)
                        .foregroundColor(ColorTheme.textGray)
                        .padding(.top)
                    
                    // Question text
                    Text(questionnaireType.questions[currentQuestion])
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(ColorTheme.textGray)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                        .padding(.horizontal)
                    
                    // Answer options
                    VStack(spacing: 10) {
                        ForEach(0..<questionnaireType.options.count, id: \.self) { index in
                            Button(action: {
                                answers[currentQuestion] = index
                                
                                if currentQuestion < questionnaireType.questions.count - 1 {
                                    currentQuestion += 1
                                } else {
                                    isCompleted = true
                                }
                            }) {
                                HStack {
                                    Text(questionnaireType.options[index])
                                        .font(.subheadline)
                                        .foregroundColor(ColorTheme.textGray)
                                    
                                    Spacer()
                                    
                                    if currentQuestion < answers.count && answers[currentQuestion] == index {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(ColorTheme.primaryPink)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(Color.gray.opacity(0.5))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            currentQuestion < answers.count && answers[currentQuestion] == index ?
                                            Color.white : Color.white.opacity(0.5)
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            currentQuestion < answers.count && answers[currentQuestion] == index ?
                                            ColorTheme.primaryPink : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack {
                        if currentQuestion > 0 {
                            Button(action: {
                                currentQuestion -= 1
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Previous")
                                }
                                .fontWeight(.medium)
                                .foregroundColor(ColorTheme.textGray)
                                .padding()
                                .frame(minWidth: 120)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                            }
                        } else {
                            Spacer().frame(minWidth: 120)
                        }
                        
                        Spacer()
                        
                        if answers[currentQuestion] != -1 {
                            Button(action: {
                                if currentQuestion < questionnaireType.questions.count - 1 {
                                    currentQuestion += 1
                                } else {
                                    isCompleted = true
                                }
                            }) {
                                HStack {
                                    Text(currentQuestion == questionnaireType.questions.count - 1 ? "Finish" : "Next")
                                    Image(systemName: "chevron.right")
                                }
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 120)
                                .background(ColorTheme.buttonGradient)
                                .cornerRadius(15)
                                .shadow(color: ColorTheme.primaryPink.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        } else {
                            Spacer().frame(minWidth: 120)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle(questionnaireType.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var scoreColor: Color {
        if questionnaireType == .epds {
            // EPDS score interpretation
            if totalScore < 10 {
                return .green
            } else if totalScore < 13 {
                return .orange
            } else {
                return .red
            }
        } else {
            // PHQ-9 score interpretation
            if totalScore < 5 {
                return .green
            } else if totalScore < 10 {
                return .orange
            } else if totalScore < 15 {
                return .orange.opacity(0.8)
            } else if totalScore < 20 {
                return .red.opacity(0.8)
            } else {
                return .red
            }
        }
    }
    
    var interpretationText: String {
        if questionnaireType == .epds {
            // EPDS score interpretation
            if totalScore < 10 {
                return "Low Risk - Your score indicates a low risk of postpartum depression."
            } else if totalScore < 13 {
                return "Possible Depression - Your score suggests possible depression. Consider discussing with a healthcare provider."
            } else {
                return "Likely Depression - Your score indicates a higher likelihood of depression. Please consult a healthcare professional."
            }
        } else {
            // PHQ-9 score interpretation
            if totalScore < 5 {
                return "Minimal Depression - Your score indicates minimal depression symptoms."
            } else if totalScore < 10 {
                return "Mild Depression - Your score suggests mild depression symptoms."
            } else if totalScore < 15 {
                return "Moderate Depression - Your score indicates moderate depression. Consider consulting a healthcare provider."
            } else if totalScore < 20 {
                return "Moderately Severe Depression - Your score suggests moderately severe depression. Please consult a healthcare professional."
            } else {
                return "Severe Depression - Your score indicates severe depression. Please seek help from a healthcare professional as soon as possible."
            }
        }
    }
    
    var recommendations: [String] {
        var baseRecommendations = [
            "Maintain regular sleep patterns",
            "Get regular physical activity, even if just a short walk",
            "Connect with friends or family members",
            "Take time for self-care activities you enjoy"
        ]
        
        if questionnaireType == .epds {
            if totalScore >= 10 {
                baseRecommendations.append("Discuss your feelings with your healthcare provider at your next appointment")
            }
            
            if totalScore >= 13 {
                baseRecommendations.append("Consider scheduling an appointment with a mental health professional")
            }
            
            if totalScore >= 16 || answers[9] > 0 { // Question 10 relates to self-harm
                baseRecommendations.insert("Contact a mental health professional soon - within the next week", at: 0)
            }
        } else { // PHQ-9
            if totalScore >= 10 {
                baseRecommendations.append("Discuss your feelings with your healthcare provider")
            }
            
            if totalScore >= 15 {
                baseRecommendations.append("Consider scheduling an appointment with a mental health professional")
            }
            
            if totalScore >= 20 || answers[8] > 0 { // Question 9 relates to self-harm
                baseRecommendations.insert("Contact a mental health professional soon - within the next week", at: 0)
            }
        }
        
        return baseRecommendations
    }
}

extension QuestionnaireType {
    var type: Self { self }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(questionnaireType: .epds)
    }
}

import SwiftUI

struct QuestionnaireView: View {
    let assessmentType: String
    
    @State private var currentQuestionIndex = 0
    @State private var answers: [Int] = []
    @State private var showResult = false
    @State private var totalScore = 0
    
    var questions: [(question: String, options: [(text: String, value: Int)])] {
        if assessmentType == "EPDS" {
            return epdsQuestions
        } else {
            return phq9Questions
        }
    }
    
    var body: some View {
        VStack {
            if showResult {
                // Results View
                resultsView
            } else {
                // Question View
                questionView
            }
        }
        .navigationTitle(assessmentType)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if currentQuestionIndex > 0 && !showResult {
                        currentQuestionIndex -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                .disabled(currentQuestionIndex == 0 || showResult)
            }
        }
    }
    
    var questionView: some View {
        VStack(spacing: 20) {
            // Progress indicator
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 100)
            }
            .padding()
            
            // Question
            Text(questions[currentQuestionIndex].question)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // Options
            VStack(spacing: 15) {
                ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                    let option = questions[currentQuestionIndex].options[index]
                    
                    Button(action: {
                        selectAnswer(option.value)
                    }) {
                        HStack {
                            Text(option.text)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if answers.count > currentQuestionIndex && answers[currentQuestionIndex] == option.value {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(answers.count > currentQuestionIndex && answers[currentQuestionIndex] == option.value ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        )
                    }
                }
            }
            .padding()
            
            Spacer()
            
            // Next/Submit Button
            Button(action: {
                if answers.count > currentQuestionIndex {
                    if currentQuestionIndex == questions.count - 1 {
                        // Calculate total score and show results
                        totalScore = answers.reduce(0, +)
                        showResult = true
                    } else {
                        // Move to next question
                        currentQuestionIndex += 1
                    }
                }
            }) {
                Text(currentQuestionIndex == questions.count - 1 ? "Submit" : "Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(answers.count > currentQuestionIndex ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!(answers.count > currentQuestionIndex))
            .padding()
        }
    }
    
    var resultsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Assessment Complete")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Your \(assessmentType) Score")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("\(totalScore)")
                    .font(.system(size: 70, weight: .bold))
                    .foregroundColor(scoreColor)
                
                // Interpretation
                VStack(alignment: .leading, spacing: 10) {
                    Text("Interpretation")
                        .font(.headline)
                    
                    Text(interpretationText)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    
                    Text("Next Steps")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(nextStepsText)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    
                    Text("Important Note")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("This assessment is not a diagnosis. If you're experiencing distress or have concerns, please consult a healthcare professional.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                }
                .padding()
                
                // Done Button
                NavigationLink(destination: ResourcesView()) {
                    Text("View Resources")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    // Helper methods
    func selectAnswer(_ value: Int) {
        if answers.count > currentQuestionIndex {
            answers[currentQuestionIndex] = value
        } else {
            answers.append(value)
        }
    }
    
    var scoreColor: Color {
        if assessmentType == "EPDS" {
            if totalScore < 10 {
                return .green
            } else if totalScore < 13 {
                return .orange
            } else {
                return .red
            }
        } else { // PHQ-9
            if totalScore < 5 {
                return .green
            } else if totalScore < 10 {
                return .blue
            } else if totalScore < 15 {
                return .orange
            } else {
                return .red
            }
        }
    }
    
    var interpretationText: String {
        if assessmentType == "EPDS" {
            if totalScore < 10 {
                return "Your score suggests a low likelihood of depression. Continue with self-care practices."
            } else if totalScore < 13 {
                return "Your score suggests possible depression. Consider speaking with a healthcare provider."
            } else {
                return "Your score suggests probable depression. It's recommended to consult with a healthcare provider soon."
            }
        } else { // PHQ-9
            if totalScore < 5 {
                return "Your score suggests minimal or no depression."
            } else if totalScore < 10 {
                return "Your score suggests mild depression."
            } else if totalScore < 15 {
                return "Your score suggests moderate depression."
            } else if totalScore < 20 {
                return "Your score suggests moderately severe depression."
            } else {
                return "Your score suggests severe depression."
            }
        }
    }
    
    var nextStepsText: String {
        if assessmentType == "EPDS" {
            if totalScore < 10 {
                return "Continue self-care practices. Revisit the assessment in 2-4 weeks."
            } else if totalScore < 13 {
                return "Consider talking to a healthcare provider. Use resources in this app for support."
            } else {
                return "Please consult with a healthcare provider. You can find Singapore-specific resources in this app."
            }
        } else { // PHQ-9
            if totalScore < 5 {
                return "Continue self-care practices."
            } else if totalScore < 10 {
                return "Consider watchful waiting and reassess in two weeks."
            } else if totalScore < 15 {
                return "Consider counseling and/or medication. Speak with a healthcare provider."
            } else {
                return "Active treatment with medication and/or therapy is recommended. Please consult a healthcare provider."
            }
        }
    }
    
    let epdsQuestions = [
        (
            question: "I have been able to laugh and see the funny side of things",
            options: [
                (text: "As much as I always could", value: 0),
                (text: "Not quite so much now", value: 1),
                (text: "Definitely not so much now", value: 2),
                (text: "Not at all", value: 3)
            ]
        ),
        (
            question: "I have looked forward with enjoyment to things",
            options: [
                (text: "As much as I ever did", value: 0),
                (text: "Rather less than I used to", value: 1),
                (text: "Definitely less than I used to", value: 2),
                (text: "Hardly at all", value: 3)
            ]
        ),
        (
            question: "I have blamed myself unnecessarily when things went wrong",
            options: [
                (text: "No, never", value: 0),
                (text: "Not very often", value: 1),
                (text: "Yes, some of the time", value: 2),
                (text: "Yes, most of the time", value: 3)
            ]
        ),
        (
            question: "I have been anxious or worried for no good reason",
            options: [
                (text: "No, not at all", value: 0),
                (text: "Hardly ever", value: 1),
                (text: "Yes, sometimes", value: 2),
                (text: "Yes, very often", value: 3)
            ]
        ),
        (
            question: "I have felt scared or panicky for no very good reason",
            options: [
                (text: "No, not at all", value: 0),
                (text: "No, not much", value: 1),
                (text: "Yes, sometimes", value: 2),
                (text: "Yes, quite a lot", value: 3)
            ]
        ),
        (
            question: "Things have been getting on top of me",
            options: [
                (text: "No, I have been coping as well as ever", value: 0),
                (text: "No, most of the time I have coped quite well", value: 1),
                (text: "Yes, sometimes I haven't been coping as well as usual", value: 2),
                (text: "Yes, most of the time I haven't been able to cope at all", value: 3)
            ]
        ),
        (
            question: "I have been so unhappy that I have had difficulty sleeping",
            options: [
                (text: "No, not at all", value: 0),
                (text: "Not very often", value: 1),
                (text: "Yes, sometimes", value: 2),
                (text: "Yes, most of the time", value: 3)
            ]
        ),
        (
            question: "I have felt sad or miserable",
            options: [
                (text: "No, not at all", value: 0),
                (text: "Not very often", value: 1),
                (text: "Yes, quite often", value: 2),
                (text: "Yes, most of the time", value: 3)
            ]
        ),
        (
            question: "I have been so unhappy that I have been crying",
            options: [
                (text: "No, never", value: 0),
                (text: "Only occasionally", value: 1),
                (text: "Yes, quite often", value: 2),
                (text: "Yes, most of the time", value: 3)
            ]
        ),
        (
            question: "The thought of harming myself has occurred to me",
            options: [
                (text: "Never", value: 0),
                (text: "Hardly ever", value: 1),
                (text: "Sometimes", value: 2),
                (text: "Yes, quite often", value: 3)
            ]
        )
    ]
    
    let phq9Questions = [
        (
            question: "Little interest or pleasure in doing things",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Feeling down, depressed, or hopeless",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Trouble falling or staying asleep, or sleeping too much",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Feeling tired or having little energy",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Poor appetite or overeating",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Trouble concentrating on things, such as reading the newspaper or watching television",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        ),
        (
            question: "Thoughts that you would be better off dead or of hurting yourself in some way",
            options: [
                (text: "Not at all", value: 0),
                (text: "Several days", value: 1),
                (text: "More than half the days", value: 2),
                (text: "Nearly every day", value: 3)
            ]
        )
    ]
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView(assessmentType: "EPDS")
    }
}

import SwiftUI

struct AssessmentHistoryView: View {
    @ObservedObject var viewModel: AssessmentViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var filteredType: AssessmentType?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Filter controls
                VStack(spacing: 12) {
                    Text("Filter by assessment type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            filteredType = nil
                        }) {
                            Text("All")
                                .font(.subheadline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(filteredType == nil ? Color("AccentColor") : Color.gray.opacity(0.1))
                                .foregroundColor(filteredType == nil ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        ForEach(AssessmentType.allCases, id: \.self) { type in
                            Button(action: {
                                filteredType = type
                            }) {
                                Text(type.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(filteredType == type ? Color("AccentColor") : Color.gray.opacity(0.1))
                                    .foregroundColor(filteredType == type ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Assessment history
                if filteredAssessments.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "clipboard")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No assessments found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(filteredType == nil ? 
                              "You haven't completed any assessments yet." : 
                              "You haven't completed any \(filteredType!.rawValue) assessments yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredAssessments) { assessment in
                            assessmentRow(assessment: assessment)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Assessment History")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                viewModel.loadAssessments()
            }
        }
    }
    
    private var filteredAssessments: [AssessmentResult] {
        if let type = filteredType {
            return viewModel.assessments.filter { $0.type == type }
        } else {
            return viewModel.assessments
        }
    }
    
    private func assessmentRow(assessment: AssessmentResult) -> some View {
        HStack(spacing: 16) {
            // Type indicator with color
            VStack(spacing: 4) {
                Image(systemName: assessment.type == .epds ? "heart.text.square.fill" : "checklist")
                    .font(.title2)
                    .foregroundColor(Color(assessment.interpretation.color))
                
                Text(assessment.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(assessment.date))
                    .font(.headline)
                
                Text(assessment.interpretation.severity)
                    .font(.subheadline)
                    .foregroundColor(Color(assessment.interpretation.color))
            }
            
            Spacer()
            
            // Score
            ZStack {
                Circle()
                    .fill(Color(assessment.interpretation.color).opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Text("\(assessment.score)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("points")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AssessmentHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AssessmentViewModel(userId: "preview_user")
        
        return AssessmentHistoryView(viewModel: viewModel)
    }
}
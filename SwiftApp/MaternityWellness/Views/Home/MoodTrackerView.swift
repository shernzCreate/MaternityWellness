import SwiftUI

struct MoodTrackerView: View {
    @ObservedObject var viewModel: MoodViewModel
    @Binding var isPresented: Bool
    @State private var selectedMood: MoodType?
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Today's date display
                Text(todayDateString)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                Text("How are you feeling today?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Mood selection
                HStack(spacing: 16) {
                    ForEach(MoodType.allCases, id: \.self) { mood in
                        moodButton(mood)
                    }
                }
                .padding()
                
                // Notes input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $notes)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save button
                Button(action: saveMood) {
                    Text("Save Mood")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedMood != nil ? Color("AccentColor") : Color.gray)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(selectedMood == nil)
                .padding(.bottom)
            }
            .navigationTitle("Track Your Mood")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
            )
            .onAppear {
                // Load existing mood if available
                if let todaysMood = viewModel.todaysMood {
                    selectedMood = todaysMood.mood
                    notes = todaysMood.notes ?? ""
                }
            }
        }
    }
    
    private func moodButton(_ mood: MoodType) -> some View {
        let isSelected = selectedMood == mood
        
        return Button(action: {
            selectedMood = mood
        }) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 32))
                
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color(mood.color) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(mood.color) : Color.clear, lineWidth: 2)
                    .background(isSelected ? Color(mood.color).opacity(0.1) : Color.clear)
                    .cornerRadius(12)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func saveMood() {
        guard let mood = selectedMood else { return }
        
        viewModel.saveMoodEntry(mood: mood, notes: notes.isEmpty ? nil : notes)
        isPresented = false
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}

struct MoodTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = MoodViewModel(userId: "preview_user")
        
        return MoodTrackerView(viewModel: viewModel, isPresented: .constant(true))
    }
}
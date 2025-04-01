import SwiftUI

struct MoodTrackerView: View {
    @EnvironmentObject private var moodViewModel: MoodViewModel
    @Binding var isPresented: Bool
    @State private var selectedMood: MoodType = .okay
    @State private var notes: String = ""
    @FocusState private var isNotesFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Mood selection section
                    VStack(spacing: 20) {
                        Text("How are you feeling today?")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 20) {
                            ForEach(MoodType.allCases, id: \.self) { mood in
                                MoodOptionButton(
                                    mood: mood,
                                    isSelected: selectedMood == mood,
                                    action: {
                                        withAnimation {
                                            selectedMood = mood
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add notes (optional)")
                            .font(.headline)
                        
                        TextField("Any thoughts or feelings you want to record...", text: $notes, axis: .vertical)
                            .focused($isNotesFocused)
                            .lineLimit(5)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onTapGesture {
                                isNotesFocused = true
                            }
                    }
                    
                    // Submit button
                    Button(action: {
                        saveMood()
                    }) {
                        HStack {
                            Text("Save")
                                .fontWeight(.bold)
                            
                            if moodViewModel.isLoading {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .disabled(moodViewModel.isLoading)
                    .opacity(moodViewModel.isLoading ? 0.6 : 1)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Track Your Mood")
            .navigationBarItems(
                trailing: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                }
            )
            .onAppear {
                if let todayMood = moodViewModel.todayMood {
                    selectedMood = todayMood.mood
                    notes = todayMood.notes ?? ""
                }
            }
        }
    }
    
    private func saveMood() {
        moodViewModel.saveMood(mood: selectedMood, notes: notes.isEmpty ? nil : notes)
        isPresented = false
    }
}

struct MoodOptionButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(mood.color) : Color.gray.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Text(mood.emoji)
                        .font(.system(size: 28))
                }
                
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color(mood.color) : .gray)
            }
        }
    }
}
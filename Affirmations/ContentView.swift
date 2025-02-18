//
//  ContentView.swift
//  Affirmations
//
//  Created by Rachael LaMassa on 2/18/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var currentAffirmation: String = "Press the button for an affirmation!"
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [.pink, .cyan], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack (spacing: 20) {
                
                Text(currentAffirmation)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(height: 200)
                
                Button {
                    fetchAffirmation()
                } label: {
                    Text("Get New Affirmation")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .shadow(radius: 12)
                
            }
            .onAppear {
                loadLastAffirmation() // load last saved affirmation when app starts
            }
        }
    }

    func fetchAffirmation() {
        let urlString = "https://www.affirmations.dev/"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                    if let newAffirmation = decodedData["affirmation"] {
                        DispatchQueue.main.async {
                            let lastAffirmation = UserDefaults.standard.string(forKey: "lastAffirmation")

                            // if the new affirmation is the same as the last, fetch again
                            if lastAffirmation == newAffirmation {
                                print("Duplicate found, fetching again...")
                                fetchAffirmation()
                                return
                            }

                            // update UI and store the new affirmation
                            currentAffirmation = newAffirmation
                            UserDefaults.standard.set(newAffirmation, forKey: "lastAffirmation")
                        }
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            } else if let error = error {
                print("API request failed: \(error.localizedDescription)")
            }
        }.resume()
    }

    func loadLastAffirmation() {
        if let savedAffirmation = UserDefaults.standard.string(forKey: "lastAffirmation") {
            currentAffirmation = savedAffirmation
        }
    }
}

#Preview {
    ContentView()
}

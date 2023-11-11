//
//  Hokuto_QuizApp.swift
//  Hokuto_Quiz
//

import SwiftUI

struct Quiz {
    let question: String
    let choices: [String]
    let correctAnswer: String
}

@main
struct HokutoQuizApp: App {
    var body: some Scene {
        WindowGroup {
            TitleView()
        }
    }
}

struct TitleView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Quiz de Show!!")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: QuizView()) {
                    Text("スタート")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct QuizView: View {
    @State private var showResults = false
    @State private var selectedAnswer: String?
    @State private var questionIndex = 0
    @State private var selectedAnswers: [String] = []
    
    let quizzes = [
        Quiz(question: "日本の首都はどこ？", choices: ["東京", "大阪", "福岡", "名古屋"], correctAnswer: "東京"),
        Quiz(question: "富士山は何県にある？", choices: ["山梨県", "静岡県", "長野県", "新潟県"], correctAnswer: "静岡県"),
        Quiz(question: "日本の最高峰は？", choices: ["御嶽山", "北アルプス", "富士山", "八ヶ岳"], correctAnswer: "富士山"),
        Quiz(question: "日本の最も古い歴史書は？", choices: ["日本書紀", "古事記", "竹取物語", "源氏物語"], correctAnswer: "古事記"),
        Quiz(question: "「鳥取砂丘」はどこの都道府県にある？", choices: ["島根県", "鳥取県", "岡山県", "広島県"], correctAnswer: "鳥取県")
    ]
    
    var body: some View {
        VStack {
            Text("問題 \(questionIndex + 1)")
                .font(.title)
                .padding()
            
            Text(quizzes[questionIndex].question)
                .font(.title2)
                .padding()
            
            VStack {
                ForEach(0..<2) { i in
                    AnswerButton(
                        text: quizzes[questionIndex].choices[i],
                        selectedAnswer: $selectedAnswer,
                        correctAnswer: quizzes[questionIndex].correctAnswer
                    )
                }
                
                ForEach(2..<4) { i in
                    AnswerButton(
                        text: quizzes[questionIndex].choices[i],
                        selectedAnswer: $selectedAnswer,
                        correctAnswer: quizzes[questionIndex].correctAnswer
                    )
                }
            }
            
            if let selectedAnswer = selectedAnswer {
                if selectedAnswer == quizzes[questionIndex].correctAnswer {
                    Text("正解！")
                        .font(.title)
                        .foregroundColor(.green)
                } else {
                    Text("間違い！")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
            
            if showResults {
                NavigationLink(destination: ResultsView(quizList: quizzes, selectedAnswers: selectedAnswers)) {
                    Text("結果を表示")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    selectedAnswers.append(selectedAnswer ?? "")
                    if questionIndex < quizzes.count - 1 {
                        questionIndex += 1
                        selectedAnswer = nil
                    } else {
                        showResults = true
                    }
                }) {
                    Text("次へ")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .opacity(selectedAnswer == nil ? 0 : 1)
            }
        }
    }
}
struct AnswerButton: View {
    let text: String
    @Binding var selectedAnswer: String?
    let correctAnswer: String
    
    var body: some View {
        Button(action: {
            selectedAnswer = text
        }) {
            Text(text)
                .font(.title2)
                .padding()
                .background(selectedAnswer == text ? (text == correctAnswer ? Color.green : Color.red) : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(selectedAnswer != nil)
        .padding()
    }
}

struct ResultsView: View {
    let quizList: [Quiz]
    let selectedAnswers: [String]
    
    private var correctAnswers: Int {
        selectedAnswers.indices.filter { selectedAnswers[$0] == quizList[$0].correctAnswer }.count
    }
    
    private var scorePercentage: Int {
        Int(Double(correctAnswers) / Double(quizList.count) * 100)
    }
    
    var body: some View {
        VStack {
            Text("正解率: \(scorePercentage)%")
                .font(.largeTitle)
                .padding()
            
            List {
                ForEach(0..<quizList.count) { i in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(quizList[i].question)
                                .font(.headline)
                            
                            Text("正解: \(quizList[i].correctAnswer)")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        
                        Text(selectedAnswers[i] == quizList[i].correctAnswer ? "正解" : "不正解")
                            .font(.headline)
                            .foregroundColor(selectedAnswers[i] == quizList[i].correctAnswer ? .green : .red)
                    }
                }
            }
            
            NavigationLink(destination: TitleView()) {
                Text("タイトルに戻る")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom)
        }
    }
}

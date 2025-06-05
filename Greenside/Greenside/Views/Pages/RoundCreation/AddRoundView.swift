//
//  AddRoundView.swift
//  Greenside
//
//  Created by Oskar Hosken on 8/5/2025.
//

import SwiftUI

struct AddRoundView: View {
  @EnvironmentObject private var tabBarVisibility: TabBarVisibility
  @StateObject private var vm = RoundCreationVM()
  @State private var showCourseSheet = false

  @State var mapType: MapType = .standard

  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      VStack {
        HStack {
          Text("Add Round")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.content)
          Spacer()
        }
        .padding(.horizontal)

        ScrollView(.vertical, showsIndicators: false) {
          VStack(alignment: .leading, spacing: 8) {
            // Title section
            VStack(alignment: .leading, spacing: 2) {
              Text("Title")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.content)
              TextField("", text: $vm.title)
                .placeholder(
                  show: vm.title.isEmpty,
                  text: "Give your round a unique title."
                )
                .padding(.horizontal)
                .frame(height: 38)
                .background(.base100)
                .cornerRadius(12)
            }
            .padding(.horizontal)

            // Date Picker section
            VStack(alignment: .leading, spacing: 2) {
              Text("Date")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.content)
              DatePicker(
                "",
                selection: $vm.roundDate,
                displayedComponents: [.date]
              )
              .datePickerStyle(.compact)
              .labelsHidden()
              .cornerRadius(12)
            }
            .padding(.horizontal)

            // Course selection field
            VStack(alignment: .leading, spacing: 2) {
              Text("Course")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.content)

              Button {
                showCourseSheet.toggle()
              } label: {
                HStack {
                  if let course = vm.selectedCourse {
                    Text(course.name)
                      .foregroundStyle(.content)

                  } else {
                    HStack(spacing: 4) {
                      Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.base400)
                      Text("Choose a course...")
                        .foregroundStyle(.base400)
                    }
                  }
                  Spacer()
                  Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.base400)

                }
                .padding(.horizontal)
                .frame(height: 40)
                .background(.base100)
                .cornerRadius(12)
              }
            }
            .padding(.horizontal)

            // Hole map section
            if vm.selectedCourse != nil && !vm.isHolesLoading {
              VStack(alignment: .leading) {
                HStack {
                  VStack(alignment: .leading) {
                    Text("Add Your Shots")
                      .font(.system(size: 24, weight: .bold))
                      .foregroundStyle(.content)
                    Text("Select any hole to start adding your shots.")
                      .font(.system(size: 16, weight: .regular))
                      .foregroundStyle(.content)
                  }
                  Spacer()
                  Button {
                    if mapType == .standard {
                      mapType = .satellite
                    } else {
                      mapType = .standard
                    }
                  } label: {
                    Image(
                      systemName: mapType == .satellite
                        ? "globe.americas.fill" : "globe.americas"
                    )
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.accentGreen)
                  }
                }
                .padding(.horizontal)

                // Hole list
                AddRoundHoleList(mapType: $mapType)
                  .environmentObject(vm)
                  .environmentObject(tabBarVisibility)

                RoundScoreTable()
                  .environmentObject(vm)
                  .padding(.top, 16)

                HStack {
                  // Save button to save shots
                  Button {
                    Task {
                      var holeScores: [Int: Int] = [:]
                      // Calculating score for each hole
                      for hole in vm.allHoles {
                        let scoreForHole = vm.scores[hole.num] ?? vm.roundShots[hole.num]?.count ?? 0
                        holeScores[hole.num] = scoreForHole
                      }
                      // Doing final score
                      let final: Int = {
                        if let manualScore = Int(vm.finalScore),
                           !vm.finalScore.isEmpty
                        {
                          return manualScore
                        }
                        return holeScores.values.reduce(0, +)
                      }()
                      
                      // Saving to firebase
                      await vm.saveRound(scores: holeScores, finalScore: final)
                    }
                    
                  } label: {
                    Text(vm.isSaving ? "Saving..." : "Save Round")
                      .font(.system(size: 20, weight: .medium))
                      .foregroundStyle(.white)
                      .padding(.vertical, 8)
                      .padding(.horizontal, 16)
                      .background(.accentGreen)
                      .cornerRadius(8)
                  }
                  .disabled(vm.isSaving || !vm.canAdvance)
                  Spacer()
                  // Reset round
                  Button {
                    vm.resetData()
                  } label: {
                    Text("Reset Round")
                      .font(.system(size: 20, weight: .medium))
                      .foregroundStyle(.white)
                      .padding(.vertical, 8)
                      .padding(.horizontal, 16)
                      .background(.lightRed)
                      .cornerRadius(8)
                  }
                }
                .padding(.horizontal)

              }
            }
            Spacer().frame(height: 100)
          }

        }

      }
    }

    .sheet(isPresented: $showCourseSheet) {
      CoursePickerSheet(vm: vm)
        .presentationDetents([.medium, .large])
    }
    .task { await vm.loadCourses() }
  }
}

struct CourseRow: View {
  let course: Course
  let isSelected: Bool

  var body: some View {
    VStack {
      HStack(spacing: 12) {
        Image(systemName: "mappin.circle")
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(.accentGreen)

        Text(course.name)
          .font(.system(size: 18, weight: .medium))
          .foregroundStyle(.content)

        Spacer()

        if isSelected {
          Image(systemName: "checkmark.seal.fill")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.primaryGreen)
        }
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 4)
      .frame(height: 36)
      Divider()
        .frame(height: 1)
        .overlay(
          Rectangle()
            .frame(height: 3)
            .foregroundColor(Color.base300)
            .cornerRadius(10)
        )
    }

  }
}

// MARK: - Entry-point sheet
struct CoursePickerSheet: View {
  @ObservedObject var vm: RoundCreationVM
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      SheetContent(vm: vm)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              vm.selectedCourse = nil
              dismiss()
            } label: {
              Text("Cancel")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.content)
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button {
              dismiss()
            } label: {
              Text("Save")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.content)
            }
          }
        }
        .background(Color.base200)
    }
  }
}

// MARK: - Lightweight content view
private struct SheetContent: View {
  @ObservedObject var vm: RoundCreationVM

  var body: some View {
    if vm.isLoading {
      ProgressView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      RoundCourseList(vm: vm)
    }
  }
}

private struct RoundCourseList: View {
  @ObservedObject var vm: RoundCreationVM

  var body: some View {
    ZStack {
      Color.base200.ignoresSafeArea()
      VStack(alignment: .leading, spacing: 4) {
        Text("Select a course")
          .font(.system(size: 28, weight: .bold))
          .foregroundStyle(.content)

        TextField("", text: $vm.courseSearch)
          .placeholder(
            show: vm.courseSearch.isEmpty,
            text: "Search for a course..."
          )
          .padding(.horizontal)
          .frame(height: 38)
          .background(.base100)
          .cornerRadius(12)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.base300, lineWidth: 2)
              .opacity(1.0)
          )
          .padding(.bottom, 8)

        ScrollView(.vertical, showsIndicators: true) {
          LazyVStack {
            ForEach(vm.filteredCourses) { course in
              CourseRow(
                course: course,
                isSelected: vm.selectedCourse?.name == course.name
              )
              .onTapGesture {
                if vm.selectedCourse?.name == course.name {
                  vm.selectedCourse = nil
                } else {
                  vm.selectedCourse = course
                  Task {
                    do {
                      await vm.loadHoles(for: course.id)
                    }
                  }
                }
              }
            }
          }
        }

        Spacer()

      }
      .padding(.horizontal)
      .onChange(of: vm.courseSearch) { vm.filterCourses(by: $0) }

    }
  }
}

#Preview {
  @Previewable @State var mapType: MapType = .standard
  AddRoundView(mapType: mapType).environmentObject(TabBarVisibility())
}

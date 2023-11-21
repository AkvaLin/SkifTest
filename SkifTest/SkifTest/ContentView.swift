//
//  ContentView.swift
//  SkifTest
//
//  Created by Никита Пивоваров on 20.11.2023.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = ViewModel()
    @State var mapView: GoogleMapsView? = nil
    
    var body: some View {
        ZStack {
            Group {
                if mapView != nil {
                    mapView
                        .ignoresSafeArea()
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            mapView?.zoomCamera(multiplier: 1.25)
                        } label: {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(width: 44, height: 44, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            BlurView(style: .systemThickMaterial)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(red: 0.75, green: 0.77, blue: 0.85), lineWidth: 0.5)),
                            alignment: .center)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                    HStack {
                        Spacer()
                        Button {
                            mapView?.zoomCamera(multiplier: 0.75)
                        } label: {
                            Image(systemName: "minus")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(width: 44, height: 44, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            BlurView(style: .systemThickMaterial)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(red: 0.75, green: 0.77, blue: 0.85), lineWidth: 0.5)),
                            alignment: .center)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 100)
                    HStack {
                        Spacer()
                        Button {
                            viewModel.isFocused.toggle()
                        } label: {
                            Image(systemName: "eye")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(viewModel.isFocused ? .white : .primary)
                                .padding(10)
                                .frame(width: 44, height: 45, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            Group {
                                if viewModel.isFocused {
                                    Color.accentColor
                                        .cornerRadius(10)
                                } else {
                                    BlurView(style: .systemThickMaterial)
                                        .cornerRadius(10)
                                }
                            }.overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.75, green: 0.77, blue: 0.85), lineWidth: 0.5)),
                            alignment: .center)
                    }
                    .padding(.trailing, 16)
                    VStack {
                        VStack(spacing: 0) {
                            Text("Бензовоз")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 16)
                            HStack {
                                Label(
                                    title: { Text(viewModel.dateRange) },
                                    icon: { Image(systemName: "calendar") }
                                )
                                Spacer()
                                Label(
                                    title: { Text("\(NSString(format:"%.1f", viewModel.totalDistance)) km") },
                                    icon: { Image(.distance) }
                                )
                                Spacer()
                                Label(
                                    title: { Text("До \(viewModel.maxSpeed)км/ч") },
                                    icon: { Image(systemName: "gauge.with.dots.needle.67percent") }
                                )
                            }
                            .font(.system(size: 12))
                            .padding(.top, 8.5)
                            if viewModel.ditances.count > 0, viewModel.speed.count > 0, viewModel.speedCalculated {
                                Slider(value: $viewModel.slider,
                                       in: ClosedRange(uncheckedBounds: (0, Double(viewModel.ditances.count-1))),
                                       step: 1)
                                .alignmentGuide(VerticalAlignment.center) { $0[VerticalAlignment.center]}
                                .padding(.top, 19)
                                .overlay(GeometryReader { gp in
                                    Text("\(Int(viewModel.speed[Int(viewModel.slider)]))км/ч")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(red: 0.61, green: 0.64, blue: 0.74))
                                        .alignmentGuide(HorizontalAlignment.leading) {
                                            $0[HorizontalAlignment.leading] - (gp.size.width - $0.width) * viewModel.slider / ( Double(viewModel.ditances.count-1) )
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }, alignment: .top)
                                .padding(.top, 14.5)
                                .onReceive(viewModel.timer) { _ in
                                    viewModel.play()
                                }
                            } else {
                                ProgressView()
                                    .padding()
                            }
                            HStack {
                                Button {
                                    viewModel.changeMultiplier()
                                } label: {
                                    Text("\(viewModel.multiplier)x")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 500))
                                        .minimumScaleFactor(0.01)
                                        .aspectRatio(1, contentMode: .fit)
                                        .lineLimit(1)
                                        .padding(12)
                                        .frame(width: 44, height: 44, alignment: .center)
                                        .contentShape(Rectangle())
                                }
                                Spacer()
                                Button {
                                    viewModel.isPlaying.toggle()
                                    viewModel.play()
                                } label: {
                                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(8)
                                        .frame(width: 44, height: 44, alignment: .center)
                                        .contentShape(Rectangle())
                                }
                                .padding(.horizontal, 113)
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut) {
                                        viewModel.showInfo.toggle()
                                    }
                                } label: {
                                    Image(systemName: viewModel.showInfo ? "info.circle.fill" : "info.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(12)
                                        .frame(width: 44, height: 44, alignment: .center)
                                        .contentShape(Rectangle())
                                }
                            }
                            .padding(.vertical, 23)
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
                    .background(
                        ZStack {
                            if colorScheme == .dark {
                                BlurView(style: .systemThickMaterialDark)
                            } else {
                                BlurView(style: .systemUltraThinMaterialLight)
                            }
                            VStack(spacing: 0) {
                                Divider()
                                    .foregroundColor(Color(red: 0.75, green: 0.77, blue: 0.85))
                                Spacer()
                            }
                        }
                            .ignoresSafeArea(),
                        alignment: .center
                    )
                    .padding(.top, 16)
                }
            }
            .disabled(viewModel.showInfo)
            if viewModel.showInfo {
                BlurView(style: .systemUltraThinMaterialDark)
                    .opacity(0.5)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Text("Легенда")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .padding(.top, 18)
                            .padding(.bottom, 14)
                        Group {
                            HStack {
                                Circle()
                                    .fill(.newBlue)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 3))
                                    .frame(width: 32, height: 32)
                                Text("- от 0 до 70 км/ч")
                                Spacer()
                            }
                            HStack {
                                Circle()
                                    .fill(.newYellow)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 3))
                                    .frame(width: 32, height: 32)
                                Text("- от 70 до 90 км/ч")
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            HStack {
                                Circle()
                                    .fill(.newRed)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 3))
                                    .frame(width: 32, height: 32)
                                Text("- более 90 км/ч")
                                Spacer()
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.leading, 89)
                        Divider()
                        Button {
                            withAnimation(.easeInOut) {
                                viewModel.showInfo.toggle()
                            }
                        } label: {
                            Text("Закрыть")
                                .fontWeight(.semibold)
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .contentShape(Rectangle())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        BlurView(style: .systemThickMaterial)
                            .ignoresSafeArea()
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.75, green: 0.77, blue: 0.85), lineWidth: 0.5)),
                        alignment: .center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 86)
                }
            }
        }
        .onAppear {
            mapView = GoogleMapsView(points: $viewModel.data, speed: $viewModel.speed)
            Task {
                await viewModel.getData()
            }
        }
        .onChange(of: viewModel.speedCalculated, perform: { _ in
            if viewModel.speed.count > 0, viewModel.speedCalculated {
                mapView?.drawPath()
            }
        })
        .onChange(of: viewModel.slider, perform: { _ in
            let data = viewModel.getDataForMarker()
            mapView?.moveMarker(latitude: data.latitude, longitude: data.longitude, angle: data.angle)
            if viewModel.isFocused {
                mapView?.moveCamera(latitude: data.latitude, longitude: data.longitude)
            }
        })
        .onChange(of: viewModel.isFocused) { _ in
            if viewModel.isFocused {
                mapView?.moveCameraToMarker()
            }
        }
    }
}

#Preview {
    ContentView()
}

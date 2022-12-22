//
//  PracticeA.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI
import iosMath

struct PracticeA: View {
    @State private var numVertices: Int?
    @State private var numEdges: Int?
    
    @State private var bAdjToA = false
    @State private var cAdjToA = false
    @State private var dAdjToA = false
    @State private var eAdjToA = false
    @State private var fAdjToA = false
    
    @State private var aAdjToD = false
    @State private var bAdjToD = false
    @State private var cAdjToD = false
    @State private var eAdjToD = false
    @State private var fAdjToD = false
    
    @State private var abAdjToCE = false
    @State private var aeAdjToCE = false
    @State private var bdAdjToCE = false
    @State private var deAdjToCE = false
    @State private var dfAdjToCE = false
    @State private var efAdjToCE = false
    @State private var loopFAdjToCE = false
    
    @State private var abAdjToDF = false
    @State private var aeAdjToDF = false
    @State private var bdAdjToDF = false
    @State private var ceAdjToDF = false
    @State private var deAdjToDF = false
    @State private var efAdjToDF = false
    @State private var loopFAdjToDF = false
    
    @State private var degreeA: Int?
    @State private var degreeB: Int?
    @State private var degreeC: Int?
    @State private var degreeD: Int?
    @State private var degreeE: Int?
    @State private var degreeF: Int?
    
    @State private var pInDeg: Int?
    @State private var pOutDeg: Int?
    @State private var qInDeg: Int?
    @State private var qOutDeg: Int?
    @State private var rInDeg: Int?
    @State private var rOutDeg: Int?
    @State private var sInDeg: Int?
    @State private var sOutDeg: Int?
    @State private var tInDeg: Int?
    @State private var tOutDeg: Int?
    @State private var uInDeg: Int?
    @State private var uOutDeg: Int?
    
    @State private var revealSolution = false
    
    var solution1 = "\\text{Let } e \\text{ represent the number of edges, and } d \\text{ the sum of degrees of vertices.}"
    var solution2 = "\\text{Since every edge contributes 2 to the sum of the degrees of vertices, then: }"
    var solution3 = "d = 2e"

    
    var body: some View {
        ScrollView {
            VStack {
                Text("Practice A")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer(minLength: 25)
                Group {
                    Text("Question #1")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                    PracticeA1()
                        .frame(width: 500, height: 500)
                    
                    Spacer(minLength: 25)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(numVertices == 6 ? .green : .gray)
                        Text("Number of vertices in the graph: ")
                        TextField("", value: $numVertices, format: .number)
                            .frame(width: 25)
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(numEdges == 8 ? .green : .gray)
                        Text("Number of edges in the graph: ")
                        TextField("", value: $numEdges, format: .number)
                            .frame(width: 25)
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                let correct = bAdjToA && !cAdjToA && !dAdjToA && eAdjToA && !fAdjToA
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("Select the vertices which are adjacent to A:")
                            }
                            Toggle("B", isOn: $bAdjToA)
                            Toggle("C", isOn: $cAdjToA)
                            Toggle("D", isOn: $dAdjToA)
                            Toggle("E", isOn: $eAdjToA)
                            Toggle("F", isOn: $fAdjToA)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                let correct = !aAdjToD && bAdjToD && !cAdjToD && eAdjToD && fAdjToD
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("Select the vertices which are adjacent to D:")
                            }
                            Toggle("A", isOn: $aAdjToD)
                            Toggle("B", isOn: $bAdjToD)
                            Toggle("C", isOn: $cAdjToD)
                            Toggle("E", isOn: $eAdjToD)
                            Toggle("F", isOn: $fAdjToD)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                let correct = !abAdjToCE && aeAdjToCE && !bdAdjToCE && deAdjToCE && !dfAdjToCE && efAdjToCE && !loopFAdjToCE
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("Select the edges which are adjacent to edge CE:")
                            }
                            Toggle("AB", isOn: $abAdjToCE)
                            Toggle("AE", isOn: $aeAdjToCE)
                            Toggle("BD", isOn: $bdAdjToCE)
                            Toggle("DE", isOn: $deAdjToCE)
                            Toggle("DF", isOn: $dfAdjToCE)
                            Toggle("EF", isOn: $efAdjToCE)
                            Toggle("Loop F", isOn: $loopFAdjToCE)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                let correct = !abAdjToDF && !aeAdjToDF && bdAdjToDF && !ceAdjToDF && deAdjToDF && efAdjToDF && loopFAdjToDF
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("Select the edges which are adjacent to edge DF:")
                            }
                            Toggle("AB", isOn: $abAdjToDF)
                            Toggle("AE", isOn: $aeAdjToDF)
                            Toggle("BD", isOn: $bdAdjToDF)
                            Toggle("CE", isOn: $ceAdjToDF)
                            Toggle("DE", isOn: $deAdjToDF)
                            Toggle("EF", isOn: $efAdjToDF)
                            Toggle("Loop F", isOn: $loopFAdjToDF)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                let correct = (degreeA == 2 && degreeB == 2 && degreeC == 1 && degreeD == 3 && degreeE == 4 && degreeF == 4)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("State the degree of each vertex:")
                            }
                            HStack {
                                let correct = (degreeA == 2)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("A")
                                TextField("", value: $degreeA, format: .number)
                                    .frame(width: 25)
                            }
                            HStack {
                                let correct = (degreeB == 2)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("B")
                                TextField("", value: $degreeB, format: .number)
                                    .frame(width: 25)
                            }
                            HStack {
                                let correct = (degreeC == 1)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("C")
                                TextField("", value: $degreeC, format: .number)
                                    .frame(width: 25)
                            }
                            HStack {
                                let correct = (degreeD == 3)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("D")
                                TextField("", value: $degreeD, format: .number)
                                    .frame(width: 25)
                            }
                            HStack {
                                let correct = (degreeE == 4)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("E")
                                TextField("", value: $degreeE, format: .number)
                                    .frame(width: 25)
                            }
                            HStack {
                                let correct = (degreeF == 4)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(correct ? .green : .gray)
                                Text("F")
                                TextField("", value: $degreeF, format: .number)
                                    .frame(width: 25)
                            }
                        }
                        Spacer()

                    }
                    .padding()
                }
                Group {
                    Text("Question #2")
                        .foregroundColor(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                    PracticeA2()
                        .frame(width: 500, height: 500)
                    Spacer(minLength: 25)
                    
                    HStack {
                        Grid {
                            GridRow {
                                Text("Vertex")
                                Text("In Degree")
                                Text("Out Degree")
                            }
                            
                            GridRow {
                                Text("P")
                                    .frame(width: 50)
                                HStack {
                                    let correct = (pInDeg == 1)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $pInDeg, format: .number)
                                        .frame(width: 25)
                                }
                                HStack {
                                    let correct = (pOutDeg == 2)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $pOutDeg, format: .number)
                                        .frame(width: 25)
                                }
                            }
                            
                            GridRow {
                                Text("Q")
                                    .frame(width: 50)
                                HStack {
                                    let correct = (qInDeg == 2)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $qInDeg, format: .number)
                                        .frame(width: 25)
                                }
                                HStack {
                                    let correct = (qOutDeg == 3)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $qOutDeg, format: .number)
                                        .frame(width: 25)
                                }
                            }
                            
                            GridRow {
                                Text("R")
                                    .frame(width: 50)
                                HStack {
                                    let correct = (rInDeg == 1)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $rInDeg, format: .number)
                                        .frame(width: 25)
                                }
                                HStack {
                                    let correct = (rOutDeg == 1)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $rOutDeg, format: .number)
                                        .frame(width: 25)
                                }
                            }
                            
                            GridRow {
                                Text("S")
                                    .frame(width: 50)
                                HStack {
                                    let correct = (sInDeg == 1)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $sInDeg, format: .number)
                                        .frame(width: 25)
                                }
                                HStack {
                                    let correct = (sOutDeg == 1)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $sOutDeg, format: .number)
                                        .frame(width: 25)
                                }
                            }
                            
                            GridRow {
                                Text("T")
                                    .frame(width: 50)
                                HStack{
                                    let correct = (tInDeg == 3)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $tInDeg, format: .number)
                                        .frame(width: 25)
                                }
                                HStack {
                                    let correct = (tOutDeg == 2)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $tOutDeg, format: .number)
                                        .frame(width: 25)
                                }
                            }
                            
                            GridRow {
                                Text("U")
                                    .frame(width: 50)
                                HStack {
                                    let correct = (uInDeg == 2)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $uInDeg, format: .number)
                                        .frame(width: 25)
                                }
                                HStack {
                                    let correct = (uOutDeg == 1)
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(correct ? .green : .gray)
                                    TextField("", value: $uOutDeg, format: .number)
                                        .frame(width: 25)
                                }
                            }
                        }
                        Spacer()
                    }
                }
                Group {
                    Text("Question #3")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer(minLength: 25)
                    PracticeA3()
                        .frame(width: 500, height: 500)
                    Spacer(minLength: 25)
                    
                    Text("For this graph, determine both the number of edges and the sum of the degrees of all the vertices. Then attempt to establish a formula relating the number of edges with the sum of the degrees of the vertices. Finally, explain why there must always be an even number of vertices of odd degree")
                        .padding()
                    
                    Button() {
                        revealSolution.toggle()
                    } label: {
                        Text(revealSolution ? "Hide Solution" : "Reveal Solution")
                    }
                    
                    if revealSolution {
                        Math(expression: solution1)
                            .frame(height: 0)
                            .padding()
                        Math(expression: solution2)
                            .frame(height: 0)
                            .padding()
                        Math(expression: solution3)
                            .frame(height: 0)
                            .padding()
                        Spacer()
                        Text("Next, we'll prove that there must always be an even number of vertices of odd degree. From the equation above, the sum of the degrees of vertices must be even. The sum of the degrees of the even vertices is even. Therefore, the sum of the degrees of the odd vertices must be even. This is true only when there are an even number of vertices of odd degree.")
                            .padding()
                    }
                    
                }
            }
        }
        .navigationTitle("Practice A")
        .padding()
        .frame(maxWidth: .infinity)
        .background(darkGray)

    }
}

struct PracticeA_Previews: PreviewProvider {
    static var previews: some View {
        PracticeA()
    }
}

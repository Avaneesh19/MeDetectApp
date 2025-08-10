import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'spline_bg.dart'; // Your centered spline background widget

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  List<Map<String, dynamic>> get reports => [
    {
      'patient': {
        'id': "PAT-958884",
        'name': "Patient Name",
        'age': "Adult",
        'gender': "Male",
        'dateOfReport': "2025-08-09T21:05:00",
      },
      'consultation': {
        'chiefComplaint': "Cough",
        'duration': "<less than 2 weeks>",
        'progression': "Stable",
        'severity': "Mild",
        'symptoms': ["Cough", "Fever"],
        'medicalHistory': ["Asthma"]
      },
      'physicalFindings': {
        'vitalSigns': {
          'temperature': "98.6",
          'pulse': "72",
          'bloodPressure': "120/80",
          'respiratoryRate': "16"
        }
      },
      'assessment': {
        'likelyDiagnosis': "Acute bronchitis",
        'confidence': "High",
        'urgency': "Non-urgent"
      }
    },
    {
      'patient': {
        'id': "PAT-159563",
        'name': "Patient Name",
        'age': "Adult",
        'gender': "Unknown",
        'dateOfReport': "2025-08-09T03:40:00",
      },
      'consultation': {
        'chiefComplaint': "Knee pain",
        'duration': "4 days",
        'progression': "Increasing",
        'severity': "Mild",
        'symptoms': ["Knee pain", "Fever", "Fatigue"],
        'medicalHistory': ["History of diabetes"]
      },
      'physicalFindings': {
        'vitalSigns': {
          'temperature': "99.2",
          'pulse': "75",
          'bloodPressure': "120/80",
          'respiratoryRate': "16"
        }
      },
      'assessment': {
        'likelyDiagnosis': "Knee joint inflammation (possible osteoarthritis exacerbation)",
        'confidence': "Medium",
        'urgency': "Non-urgent"
      }
    },
    {
      'patient': {
        'id': "PAT-653642",
        'name': "Not specified",
        'age': 35,
        'gender': "Unknown",
        'dateOfReport': "2025-08-09T21:01:00",
      },
      'consultation': {
        'chiefComplaint': "Cough",
        'duration': "More than 2 weeks",
        'progression': "Persistent",
        'severity': "Mild",
        'symptoms': ["Cough", "Phlegm/mucus"],
        'medicalHistory': ["Existing medical conditions"]
      },
      'physicalFindings': {
        'vitalSigns': {
          'temperature': "98.6",
          'pulse': "72",
          'bloodPressure': "120/80",
          'respiratoryRate': "16"
        }
      },
      'assessment': {
        'likelyDiagnosis': "Chronic cough syndrome",
        'confidence': "Medium",
        'urgency': "Non-urgent"
      }
    }
  ];

  Map<String, dynamic> get trends {
    final symptomsMap = <String, int>{};
    final diagnosesMap = <String, int>{};
    final severityMap = {'Mild': 0, 'Moderate': 0, 'Severe': 0};
    final urgencyMap = {'Non-urgent': 0, 'Urgent': 0, 'Emergency': 0};
    final confidenceMap = {'High': 0, 'Medium': 0, 'Low': 0};

    for (var report in reports) {
      final symptoms = (report['consultation']?['symptoms'] as List?) ?? [];
      for (var s in symptoms) {
        symptomsMap[s] = (symptomsMap[s] ?? 0) + 1;
      }
      final diagnosis = report['assessment']?['likelyDiagnosis'] ?? "";
      if (diagnosis.isNotEmpty) {
        diagnosesMap[diagnosis] = (diagnosesMap[diagnosis] ?? 0) + 1;
      }
      final severity = report['consultation']?['severity'] ?? "";
      if (severity.isNotEmpty && severityMap.containsKey(severity)) {
        severityMap[severity] = (severityMap[severity] ?? 0) + 1;
      }
      final urgency = report['assessment']?['urgency'] ?? "Non-urgent";
      if (urgencyMap.containsKey(urgency)) {
        urgencyMap[urgency] = (urgencyMap[urgency] ?? 0) + 1;
      }
      final confidence = report['assessment']?['confidence'] ?? "Medium";
      if (confidenceMap.containsKey(confidence)) {
        confidenceMap[confidence] = (confidenceMap[confidence] ?? 0) + 1;
      }
    }
    return {
      'symptoms': symptomsMap,
      'diagnoses': diagnosesMap,
      'severityLevels': severityMap,
      'urgencyLevels': urgencyMap,
      'confidenceLevels': confidenceMap,
      'totalPatients': reports.length,
    };
  }

  List<Map<String, dynamic>> getVitalsTrend() {
    return reports.asMap().entries.map((e) {
      final v = e.value['physicalFindings']['vitalSigns'];
      final bp = (v['bloodPressure'] ?? "120/80").split('/');
      return {
        'report': 'Report ${e.key + 1}',
        'temperature': double.tryParse(v['temperature'] ?? "98.6") ?? 98.6,
        'pulse': int.tryParse(v['pulse'] ?? "72") ?? 72,
        'systolic': int.tryParse(bp.isNotEmpty ? bp[0] : "120") ?? 120,
        'diastolic': int.tryParse(bp.length > 1 ? bp[1] : "80") ?? 80,
        'respiratory': int.tryParse(v['respiratoryRate'] ?? "16") ?? 16,
        'date': DateTime.tryParse(e.value['patient']['dateOfReport'] ?? "")?.toString().split(' ')[0] ?? '',
      };
    }).toList();
  }

  int get healthScore {
    final t = trends;
    final urgent = ((t['urgencyLevels']?['Urgent'] ?? 0) as int) + ((t['urgencyLevels']?['Emergency'] ?? 0) as int);
    final int chronic = reports.where((r) =>
      (r['consultation']?['duration']?.toString().contains('weeks') ?? false) ||
      (r['consultation']?['progression'] == 'Persistent')).length;
    final int feverCases = reports.where((r) => (r['consultation']?['symptoms'] ?? []).contains('Fever')).length;
    return max(0, 100 - urgent * 20 - chronic * 15 - feverCases * 10);
  }

  double get averageConfidence {
    return reports.fold<double>(0.0, (sum, r) {
      final c = r['assessment']?['confidence'];
      return sum + (c == 'High' ? 0.9 : c == 'Medium' ? 0.7 : 0.5);
    }) / reports.length;
  }

  @override
  Widget build(BuildContext context) {
    final vitalsTrend = getVitalsTrend();
    final chartColors = [
      Colors.blue,
      Colors.purple,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.cyan,
    ];
    final t = trends;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Medical Analytics Dashboard"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const CenteredSplineBg(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ExpansionTile(
                    title: const Text("Key Metrics", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetricCard(
                            title: "Total Reports",
                            value: "${reports.length}",
                            subtitle: "Active monitoring",
                            valueColor: Colors.blue[300],
                          ),
                          _MetricCard(
                            title: "Health Score",
                            value: "$healthScore",
                            subtitle: healthScore >= 80
                                ? "Excellent"
                                : healthScore >= 60
                                    ? "Good"
                                    : "Needs attention",
                            valueColor: Colors.green[300],
                          ),
                          _MetricCard(
                            title: "Avg. Confidence",
                            value: "${(averageConfidence * 100).toStringAsFixed(0)}%",
                            subtitle: "Diagnostic accuracy",
                            valueColor: Colors.purple[300],
                          ),
                          _MetricCard(
                            title: "Chronic Cases",
                            value: "${reports.where((r) => (r['consultation']?['duration']?.toString().contains('weeks') ?? false)).length}",
                            subtitle: "Requires monitoring",
                            valueColor: Colors.orange[300],
                          ),
                          _MetricCard(
                            title: "Avg Temperature",
                            value: "${(vitalsTrend.map((v) => v['temperature'] as double).reduce((a, b) => a + b) / vitalsTrend.length).toStringAsFixed(1)}°F",
                            subtitle: "Within normal range",
                            valueColor: Colors.red[300],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text("Vital Signs Progression", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      SizedBox(
                        height: 260,
                        child: LineChart(
                          LineChartData(
                            minY: 95,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 36),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, meta) {
                                    int idx = value.toInt();
                                    if (idx < vitalsTrend.length) {
                                      return Text(vitalsTrend[idx]['date'], style: const TextStyle(fontSize: 10, color: Colors.white));
                                    }
                                    return const Text('');
                                  },
                                  interval: 1,
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: vitalsTrend
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(e.key.toDouble(), (e.value['temperature'] as double?) ?? 98.6))
                                    .toList(),
                                isCurved: true,
                                color: Colors.redAccent,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                              LineChartBarData(
                                spots: vitalsTrend
                                    .asMap()
                                    .entries
                                    .map((e) => FlSpot(e.key.toDouble(), ((e.value['pulse'] as num?) ?? 72).toDouble()))
                                    .toList(),
                                isCurved: true,
                                color: Colors.blueAccent,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text("Diagnostic Confidence", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: (t['confidenceLevels']?['High'] ?? 0).toDouble(),
                                color: Colors.green,
                                title: "High",
                                radius: 38,
                                titleStyle: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              PieChartSectionData(
                                value: (t['confidenceLevels']?['Medium'] ?? 0).toDouble(),
                                color: Colors.orange,
                                title: "Medium",
                                radius: 38,
                                titleStyle: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              PieChartSectionData(
                                value: (t['confidenceLevels']?['Low'] ?? 0).toDouble(),
                                color: Colors.redAccent,
                                title: "Low",
                                radius: 38,
                                titleStyle: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                            sectionsSpace: 4,
                            centerSpaceRadius: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text("Blood Pressure Tracking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceBetween,
                            barGroups: List.generate(vitalsTrend.length, (i) {
                              return BarChartGroupData(x: i, barRods: [
                                BarChartRodData(
                                  toY: ((vitalsTrend[i]['systolic'] as num?) ?? 120).toDouble(),
                                  color: Colors.blue[200],
                                  width: 12,
                                ),
                                BarChartRodData(
                                  toY: ((vitalsTrend[i]['diastolic'] as num?) ?? 80).toDouble(),
                                  color: Colors.purple[400],
                                  width: 12,
                                ),
                              ]);
                            }),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 20),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, meta) {
                                    int i = value.toInt();
                                    if (i < vitalsTrend.length) {
                                      return Text(
                                        vitalsTrend[i]['date'].toString(),
                                        style: const TextStyle(fontSize: 8, color: Colors.white),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  interval: 1,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            barTouchData: BarTouchData(enabled: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text("Symptom Analysis", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            barGroups: List.generate((t['symptoms'] as Map<String, int>).length, (i) {
                              final symptom = (t['symptoms'] as Map<String, int>).keys.elementAt(i);
                              final value = (t['symptoms'] as Map<String, int>)[symptom] ?? 0;
                              return BarChartGroupData(x: i, barRods: [
                                BarChartRodData(
                                  toY: value.toDouble(),
                                  color: chartColors[i % chartColors.length],
                                  width: 20,
                                )
                              ]);
                            }),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 23),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, meta) {
                                    final idx = value.toInt();
                                    if (idx < (t['symptoms'] as Map<String, int>).length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          (t['symptoms'] as Map<String, int>).keys.elementAt(idx),
                                          style: const TextStyle(fontSize: 9, color: Colors.white),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  interval: 1,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            barTouchData: BarTouchData(enabled: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text("Medical History Timeline", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      ...reports.asMap().entries.map((e) {
                        final report = e.value;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(color: Colors.blueAccent, width: 5),
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${e.key + 1}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                              ),
                            ),
                            title: Text(
                              report['assessment']?['likelyDiagnosis'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFb4e0fe),
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Chief: ${report['consultation']?['chiefComplaint'] ?? ''} • Duration: ${report['consultation']?['duration'] ?? ''} • Severity: ${report['consultation']?['severity'] ?? ''}",
                                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                                ),
                                Wrap(
                                  spacing: 2,
                                  runSpacing: 0,
                                  children: [
                                    Text(
                                      "Symptoms: ${(report['consultation']?['symptoms'] ?? []).join(", ")}",
                                      style: const TextStyle(fontSize: 9, color: Colors.white70),
                                    ),
                                    const SizedBox(width: 24),
                                    Text(
                                      "Medical history: ${(report['consultation']?['medicalHistory'] ?? []).join(", ")}",
                                      style: const TextStyle(fontSize: 9, color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${report['assessment']?['confidence'] ?? ''} confidence",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: report['assessment']?['confidence'] == 'High'
                                          ? Colors.greenAccent
                                          : report['assessment']?['confidence'] == 'Medium'
                                              ? Colors.orange
                                              : Colors.redAccent,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  (report['patient']?['dateOfReport'] ?? '').toString().split('T').first,
                                  style: const TextStyle(fontSize: 9, color: Colors.white30),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text("Health Insights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      _InsightsPanel(trends: t, reports: reports, vitalsTrend: vitalsTrend),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ExpansionTile(
                    title: const Text("Quick Actions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    children: [
                      _PanelCard(
                        title: "Quick Actions",
                        iconColor: Colors.indigoAccent,
                        height: 145,
                        child: Column(
                          children: [
                            _QuickActionButton(icon: Icons.description, label: "Generate Full Report"),
                            _QuickActionButton(icon: Icons.download, label: "Export Analytics"),
                            _QuickActionButton(icon: Icons.notifications_active, label: "Set Alerts"),
                            _QuickActionButton(icon: Icons.calendar_today_sharp, label: "Schedule Follow-up"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Helper Widgets ----------
class _MetricCard extends StatelessWidget {
  final String title, value, subtitle;
  final Color? valueColor;
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 130),
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.21)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: valueColor ?? Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final Color iconColor;
  final double? height;
  final Widget child;
  const _PanelCard({
    required this.title,
    required this.iconColor,
    required this.child,
    this.height = 180,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickActionButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.07),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// ---- INSIGHTS PANEL ----
class _InsightsPanel extends StatelessWidget {
  final Map<String, dynamic> trends;
  final List reports;
  final List vitalsTrend;
  const _InsightsPanel({required this.trends, required this.reports, required this.vitalsTrend});

  @override
  Widget build(BuildContext context) {
    final sortedSymptoms = (trends['symptoms'] as Map<String, int>).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSymptom = sortedSymptoms.isNotEmpty ? sortedSymptoms.first : null;

    final sortedDiagnosis = (trends['diagnoses'] as Map<String, int>).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mostDiagnosis = sortedDiagnosis.isNotEmpty ? sortedDiagnosis.first : null;

    final nonUrgentCount = (trends['urgencyLevels']?['Non-urgent'] ?? 0) as int;
    final respiratoryCases = reports.where((r) => (r['consultation']?['symptoms'] ?? []).contains('Cough')).length;
    final feverCases = reports.where((r) => (r['consultation']?['symptoms'] ?? []).contains('Fever')).length;
    final avgPulse = vitalsTrend.isNotEmpty
        ? vitalsTrend.map((v) => (v['pulse'] as num?)?.toInt() ?? 72).reduce((a, b) => a + b) ~/ vitalsTrend.length
        : 72;

    return Column(
      children: [
        _InsightTile(
          icon: "🔍",
          title: "Pattern Analysis",
          value: topSymptom != null
              ? "${topSymptom.key} appears most frequently (${topSymptom.value} cases)"
              : "No dominant pattern",
          color: Colors.blue[200],
        ),
        _InsightTile(
          icon: "✅",
          title: "Health Status",
          value: nonUrgentCount == reports.length
              ? "All conditions are stable and non-urgent"
              : "$nonUrgentCount/${reports.length} conditions are stable",
          color: Colors.green[200],
        ),
        _InsightTile(
          icon: "⚠️",
          title: "Monitoring Points",
          value: "$respiratoryCases respiratory-related, $feverCases cases with fever, avg pulse $avgPulse bpm",
          color: Colors.yellow[200],
        ),
        _InsightTile(
          icon: "🎯",
          title: "Recommendations",
          value: "Continue monitoring | Focus on respiratory management | Maintain medication adherence",
          color: Colors.purple[200],
        ),
        _InsightTile(
          icon: "📈",
          title: "Trend Summary",
          value: mostDiagnosis != null
              ? "Most common: ${mostDiagnosis.key.substring(0, min(15, mostDiagnosis.key.length))}... | Severity: Mostly mild"
              : "No trend summary",
          color: Colors.indigo[200],
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final String icon, title, value;
  final Color? color;
  const _InsightTile({required this.icon, required this.title, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.13) ?? Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: (color ?? Colors.white).withOpacity(0.24), width: 1),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 19)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(value, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

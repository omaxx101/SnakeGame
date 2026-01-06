import 'package:flutter/material.dart';
import 'game.dart'; // make sure highScores is imported

const green = Colors.green;
const black = Colors.black;

class ScoreTab extends StatelessWidget {
  const ScoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top 5 Best Scores:',
            style: TextStyle(
                color: green, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(child: const ScoreList()),
        ],
      ),
    );
  }
}

class ScoreList extends StatelessWidget {
  const ScoreList({super.key});

  @override
  Widget build(BuildContext context) {
    if (highScores.isEmpty) {
      return const Center(
        child: Text(
          'No scores yet!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.green.withOpacity(0.3)),
          columns: const [
            DataColumn(
              label: Text('Rank',
                  style: TextStyle(
                      color: green, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            DataColumn(
              label: Text('Name',
                  style: TextStyle(
                      color: green, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            DataColumn(
              label: Text('Score',
                  style: TextStyle(
                      color: green, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            DataColumn(
              label: Text('Date',
                  style: TextStyle(
                      color: green, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
          rows: List.generate(highScores.length, (index) {
            final scoreEntry = highScores[index];
            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(scoreEntry['name'] ?? 'Unknown')),
                DataCell(Text('${scoreEntry['score']}')),
                DataCell(Text(scoreEntry['date'] ?? '')),
              ],
            );
          }),
        ),
      ),
    );
  }
}

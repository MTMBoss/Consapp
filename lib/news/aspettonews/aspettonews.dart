import 'package:flutter/material.dart';

class AspettoNews extends StatelessWidget {
  final List<Map<String, String>> newsList;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<Map<String, String>> onNewsTap;
  final bool isLoading;
  final String errorMessage;

  const AspettoNews({
    super.key,
    required this.newsList,
    required this.initialDate,
    required this.onDateChanged,
    required this.onYearChanged,
    required this.onNewsTap,
    required this.isLoading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                onDateChanged(pickedDate);
              }
            },
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_alt),
            onSelected: (year) => onYearChanged(year),
            itemBuilder: (context) {
              int currentYear = DateTime.now().year;
              return List.generate(
                currentYear - 1999,
                (index) => PopupMenuItem(
                  value: currentYear - index,
                  child: Text('${currentYear - index}'),
                ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : newsList.isEmpty
              ? const Center(
                child: Text('Nessuna notizia trovata per la data selezionata.'),
              )
              : ListView.builder(
                itemCount: newsList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(newsList[index]['title']!),
                      subtitle: Text(newsList[index]['date']!),
                      onTap: () {
                        onNewsTap(newsList[index]);
                      },
                    ),
                  );
                },
              ),
    );
  }
}

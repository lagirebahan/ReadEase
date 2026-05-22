import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/note_card.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget{
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage>{
  bool _isLoading = true;

  List<dynamic> _allNotes = [];
  List<dynamic> _pinned = [];
  List<dynamic> _filtered = [];
  List<dynamic> _noteGroups = [];
  String _selectedGroup = 'All';

  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final data = [
      {
        'note_title': 'Biology Notes',
        'note_group': 'School',
        'image': 'https://picsum.photos/200',
        'updated_at': 'May 20, 2026',
        'is_pinned': true,
      },
      {
        'note_title': 'Math Formula',
        'note_group': 'Lecture',
        'image': 'https://picsum.photos/201',
        'updated_at': 'May 18, 2026',
        'is_pinned': true,
      },
      {
        'note_title': 'Chemistry Review',
        'note_group': 'School',
        'image': 'https://picsum.photos/202',
        'updated_at': 'May 17, 2026',
        'is_pinned': false,
      },
      {
        'note_title': 'Physics Equations',
        'note_group': 'School',
        'image': 'https://picsum.photos/203',
        'updated_at': 'May 15, 2026',
        'is_pinned': true,
      },
      {
        'note_title': 'History Essay',
        'note_group': 'School',
        'image': 'https://picsum.photos/205',
        'updated_at': 'May 12, 2026',
        'is_pinned': false,
      },
    ];

    final groups = [
      'All',
      ...data
          .map((e) => e['note_group'].toString())
          .toSet(),
    ];

    final pinned = data
        .where((n) => n['is_pinned'] == true)
        .take(4)
        .toList();

    setState(() {

      _allNotes = data;
      _pinned = pinned;
      _filtered = data;

      _noteGroups =
          groups.cast<String>();

      _isLoading = false;
    });
  }

  void _applyFilter() {
    final query =
      _searchController.text.toLowerCase();

    setState(() {
      _filtered =
          _allNotes.where((note) {

        final title =
            note['note_title']
                .toString()
                .toLowerCase();

        final group =
            note['note_group']
                .toString();

        final matchesSearch =
            title.contains(query);

        final matchesGroup =
            _selectedGroup == 'All'
                ? true
                : group == _selectedGroup;

        return matchesSearch &&
            matchesGroup;

      }).toList();
    });
  }

  Widget _buildPinnedStrip(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              const Icon(Icons.pin, size: 16,),
              // const Text('📌', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Pinned',
                style: theme
                    .baseTextStyle(theme.primaryTextColor)
                    .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _pinned.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            return NoteCard(note: _pinned[index], theme: theme);
          },
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();
    return Column(
      children: [
        if(!_isLoading && _pinned.isNotEmpty) _buildPinnedStrip(theme),
        Padding(
          padding: const EdgeInsets.all(16),

          child: TextField(
            controller: _searchController,

            decoration: InputDecoration(
              hintText: 'Search notes...',
              prefixIcon:
                  const Icon(Icons.search),
            ),
          ),
        ),

        SizedBox(
          height: 40,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),

            itemBuilder: (context, index) {

              final group =
                  _noteGroups[index];

              final selected =
                  group == _selectedGroup;

              return ChoiceChip(
                label: Text(group),

                selected: selected,

                onSelected: (_) {

                  setState(() {
                    _selectedGroup = group;
                  });

                  _applyFilter();
                },
              );
            },

            separatorBuilder:
                (_, __) =>
                    const SizedBox(width: 8),

            itemCount: _noteGroups.length,
          ),
        ),

        Expanded(
          child: _isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : _filtered.isEmpty

                  ? const Center(
                      child:
                          Text('No notes found'),
                    )

                  : GridView.builder(

                      padding:
                          const EdgeInsets.all(16),

                      itemCount:
                          _filtered.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                      ),

                      itemBuilder:
                          (context, index) {

                        final note =
                            _filtered[index];

                        return NoteCard(
                          note: note,
                          theme: theme,
                        );
                      },
                    ),
        ),

      ],
    );
  }
}
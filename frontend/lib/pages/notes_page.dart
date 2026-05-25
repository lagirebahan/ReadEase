// import 'package:flutter/material.dart';
// import 'package:frontend/theme/app_theme.dart';
// import 'package:frontend/widgets/note_card.dart';
// import 'package:provider/provider.dart';

// class NotesPage extends StatefulWidget{
//   const NotesPage({super.key});

//   @override
//   State<NotesPage> createState() => _NotesPageState();
// }

// class _NotesPageState extends State<NotesPage>{
//   bool _isLoading = true;

//   List<dynamic> _allNotes = [];
//   List<dynamic> _pinned = [];
//   List<dynamic> _filtered = [];
//   List<dynamic> _noteGroups = [];
//   String _selectedGroup = 'All';

//   final TextEditingController _searchController = TextEditingController();
  
//   @override
//   void initState() {
//     super.initState();
//     _loadNotes();
//     _searchController.addListener(_applyFilter);
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _loadNotes() async {
//     await Future.delayed(
//       const Duration(milliseconds: 500),
//     );

//     final data = [
//       {
//         'note_title': 'Biology Notes',
//         'note_group': 'School',
//         'image': 'https://picsum.photos/200',
//         'updated_at': 'May 20, 2026',
//         'is_pinned': true,
//       },
//       {
//         'note_title': 'Math Formula',
//         'note_group': 'Lecture',
//         'image': 'https://picsum.photos/201',
//         'updated_at': 'May 18, 2026',
//         'is_pinned': true,
//       },
//       {
//         'note_title': 'Chemistry Review',
//         'note_group': 'School',
//         'image': 'https://picsum.photos/202',
//         'updated_at': 'May 17, 2026',
//         'is_pinned': false,
//       },
//       {
//         'note_title': 'Physics Equations',
//         'note_group': 'School',
//         'image': 'https://picsum.photos/203',
//         'updated_at': 'May 15, 2026',
//         'is_pinned': true,
//       },
//       {
//         'note_title': 'History Essay',
//         'note_group': 'School',
//         'image': 'https://picsum.photos/205',
//         'updated_at': 'May 12, 2026',
//         'is_pinned': false,
//       },
//     ];

//     final groups = [
//       'All',
//       ...data
//           .map((e) => e['note_group'].toString())
//           .toSet(),
//     ];

//     final pinned = data
//         .where((n) => n['is_pinned'] == true)
//         .take(4)
//         .toList();

//     setState(() {

//       _allNotes = data;
//       _pinned = pinned;
//       _filtered = data;

//       _noteGroups =
//           groups.cast<String>();

//       _isLoading = false;
//     });
//   }

//   void _applyFilter() {
//     final query =
//       _searchController.text.toLowerCase();

//     setState(() {
//       _filtered =
//           _allNotes.where((note) {

//         final title =
//             note['note_title']
//                 .toString()
//                 .toLowerCase();

//         final group =
//             note['note_group']
//                 .toString();

//         final matchesSearch =
//             title.contains(query);

//         final matchesGroup =
//             _selectedGroup == 'All'
//                 ? true
//                 : group == _selectedGroup;

//         return matchesSearch &&
//             matchesGroup;

//       }).toList();
//     });
//   }

//   Widget _buildPinnedStrip(AppTheme theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
//           child: Row(
//             children: [
//               const Icon(Icons.pin, size: 16,),
//               // const Text('📌', style: TextStyle(fontSize: 16)),
//               const SizedBox(width: 6),
//               Text(
//                 'Pinned',
//                 style: theme
//                     .baseTextStyle(theme.primaryTextColor)
//                     .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           itemCount: _pinned.length,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 0.65,
//           ),
//           itemBuilder: (context, index) {
//             return NoteCard(note: _pinned[index], theme: theme);
//           },
//         ),
//         const SizedBox(height: 8),
//         const Divider(height: 1),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = context.watch<AppTheme>();
//     return Column(
//       children: [
//         if(!_isLoading && _pinned.isNotEmpty) _buildPinnedStrip(theme),
//         Padding(
//           padding: const EdgeInsets.all(10),

//           child: TextField(
//             controller: _searchController,

//             decoration: InputDecoration(
//               hintText: 'Search notes...',
//               prefixIcon:
//                   const Icon(Icons.search),
//             ),
//           ),
//         ),

//         SizedBox(
//           height: 40,

//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,

//             padding:
//                 const EdgeInsets.symmetric(
//                     horizontal: 16),

//             itemBuilder: (context, index) {

//               final group =
//                   _noteGroups[index];

//               final selected =
//                   group == _selectedGroup;

//               return ChoiceChip(
//                 label: Text(group),

//                 selected: selected,

//                 onSelected: (_) {

//                   setState(() {
//                     _selectedGroup = group;
//                   });

//                   _applyFilter();
//                 },
//               );
//             },

//             separatorBuilder:
//                 (_, __) =>
//                     const SizedBox(width: 8),

//             itemCount: _noteGroups.length,
//           ),
//         ),

//         Expanded(
//           child: _isLoading

//               ? const Center(
//                   child:
//                       CircularProgressIndicator(),
//                 )

//               : _filtered.isEmpty

//                   ? const Center(
//                       child:
//                           Text('No notes found'),
//                     )

//                   : GridView.builder(

//                       padding:
//                           const EdgeInsets.all(16),

//                       itemCount:
//                           _filtered.length,

//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 12,
//                         mainAxisSpacing: 12,
//                         childAspectRatio: 0.65,
//                       ),

//                       itemBuilder:
//                           (context, index) {

//                         final note =
//                             _filtered[index];

//                         return NoteCard(
//                           note: note,
//                           theme: theme,
//                         );
//                       },
//                     ),
//         ),

//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:frontend/models/note.dart';
import 'package:frontend/services/note_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/note_card.dart';
import 'package:frontend/pages/reader_page.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _isLoading = true;
  String? _error;
  bool _pinnedExpanded = true;

  List<Note> _allNotes = [];
  List<Note> _pinned = [];
  List<Note> _filtered = [];
  List<String> _noteGroups = ['All'];
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

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notes = await NoteService.getNotes();
      final groups = await NoteService.getGroups();

      setState(() {
        _allNotes = notes;
        _pinned = notes.where((n) => n.isPinned).take(4).toList();
        _filtered = notes;
        _noteGroups = ['All', ...groups];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onGroupSelected(String group) async {
    setState(() => _selectedGroup = group);
    try {
      final notes = await NoteService.getNotes(tag: group == 'All' ? null : group);
      setState(() => _allNotes = notes);
      _applyFilter();
    } catch (_) {
      _applyFilter();
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _allNotes.where((note) {
        final matchesSearch = note.title.toLowerCase().contains(query);
        final matchesGroup = _selectedGroup == 'All'
            ? true
            : note.noteGroup == _selectedGroup;
        return matchesSearch && matchesGroup;
      }).toList();
    });
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderPage(
          noteId: note.noteId,
          initialTitle: note.title,
          initialText: note.extractedText,
          noteGroup: note.noteGroup,
          isPinned: note.isPinned,
        ),
      ),
    ).then((_) => _loadNotes());
  }

  Widget _buildPinnedStrip(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _pinnedExpanded = !_pinnedExpanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.push_pin, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Pinned',
                  style: theme
                      .baseTextStyle(theme.primaryTextColor)
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _pinnedExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: theme.primaryTextColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _pinnedExpanded
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _pinned.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openNote(_pinned[index]),
                      child: NoteCard(
                        note: _pinned[index].toDisplayMap(),
                        theme: theme,
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Could not connect to server',
                style: theme.baseTextStyle(theme.primaryTextColor)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadNotes, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: Column(
        children: [
          if (_pinned.isNotEmpty) _buildPinnedStrip(theme),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.borderColor),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _noteGroups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final group = _noteGroups[index];
                return ChoiceChip(
                  label: Text(group),
                  selected: group == _selectedGroup,
                  onSelected: (_) => _onGroupSelected(group),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text('No notes found',
                        style: theme.baseTextStyle(
                            theme.primaryTextColor.withOpacity(0.5))),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final note = _filtered[index];
                      return GestureDetector(
                        onTap: () => _openNote(note),
                        child: NoteCard(
                          note: note.toDisplayMap(),
                          theme: theme,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
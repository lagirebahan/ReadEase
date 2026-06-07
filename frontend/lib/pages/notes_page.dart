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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notes = await NoteService.getNotes();
      final groups = await NoteService.getFolders();

      if (!mounted) return;
      setState(() {
        _allNotes = notes;
        _pinned = notes.where((n) => n.isPinned).take(4).toList();
        _filtered = notes;
        _noteGroups = ['All', ...groups];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDeleteFolder(String groupName) async {
    final theme = context.read<AppTheme>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surfaceBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete Folder',
            style: TextStyle(color: theme.primaryTextColor, fontFamily: 'Georgia')),
        content: Text(
          'Are you sure you want to delete the folder "$groupName"? All notes inside it will be moved to Uncategorized.',
          style: TextStyle(color: theme.primaryTextColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: theme.primaryTextColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await NoteService.deleteFolder(groupName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Folder "$groupName" deleted!'),
          backgroundColor: Colors.green[700],
        ),
      );
      setState(() {
        _selectedGroup = 'All';
      });
      _loadNotes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete folder: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
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
      child: CustomScrollView(
        slivers: [
          if (_pinned.isNotEmpty) SliverToBoxAdapter(child: _buildPinnedStrip(theme),) ,

          SliverToBoxAdapter(
            child: Padding(
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
          ),
          SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
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
                ),
                if (_selectedGroup != 'All' && _selectedGroup != 'Uncategorized')
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                      tooltip: 'Delete folder',
                      onPressed: () => _confirmDeleteFolder(_selectedGroup),
                    ),
                  ),
              ],
            ),
          ),
          

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          if(_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text('No notes found',
                  style: theme.baseTextStyle(
                    theme.primaryTextColor.withOpacity(0.5))),
              )
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = _filtered[index];
                    return GestureDetector(
                      onTap: () => _openNote(note),
                      child: NoteCard(
                        note: note.toDisplayMap(),
                        theme: theme,
                      ),
                    );
                  },
                  childCount: _filtered.length,
                ), 
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
              ),
            )

          
        ],
      ),
    );
  }
}
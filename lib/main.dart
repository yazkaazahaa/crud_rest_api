import 'package:flutter/material.dart';

import 'user_model.dart';
import 'user_service.dart';

void main() {
  runApp(const MyApp());
}

const Color marun = Color(0xFF800000);
const Color marunMuda = Color(0xFFF7E8EA);
const Color latar = Color(0xFFFFFAFA);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: marun,
          primary: marun,
          secondary: const Color(0xFFB76E79),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: latar,
        appBarTheme: const AppBarTheme(
          backgroundColor: marun,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: marun, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: marun,
            foregroundColor: Colors.white,
          ),
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: marun),
      ),
      home: const UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService service = UserService();
  late Future<List<UserModel>> usersFuture;
  List<UserModel> currentUsers = [];

  @override
  void initState() {
    super.initState();
    usersFuture = _loadUsers();
  }

  Future<List<UserModel>> _loadUsers() async {
    final users = await service.getUsers();
    currentUsers = users;
    return users;
  }

  void refreshUsers() {
    setState(() {
      usersFuture = _loadUsers();
    });
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Colors.red.shade700 : marun,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> openForm({UserModel? user}) async {
    final result = await showDialog<_FormResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserFormDialog(user: user, service: service),
    );

    if (!mounted || result == null) return;

    setState(() {
      if (result.deletedId != null) {
        currentUsers.removeWhere((item) => item.id == result.deletedId);
      } else if (result.user != null) {
        final index = currentUsers.indexWhere(
          (item) => item.id == result.user!.id,
        );
        if (index == -1) {
          currentUsers = [result.user!, ...currentUsers];
        } else {
          currentUsers[index] = result.user!;
        }
      }
      usersFuture = Future.value(List<UserModel>.from(currentUsers));
    });

    _showMessage(result.message);
  }

  Future<void> removeUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus User?'),
        content: Text('Apakah kamu yakin ingin menghapus ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await service.deleteUser(user.id);
      if (!mounted) return;
      setState(() {
        currentUsers.removeWhere((item) => item.id == user.id);
        usersFuture = Future.value(List<UserModel>.from(currentUsers));
      });
      _showMessage('Permintaan hapus berhasil dikirim.');
    } catch (e) {
      _showMessage(_cleanError(e), error: true);
    }
  }

  String _cleanError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: refreshUsers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openForm(),
        backgroundColor: marun,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah User'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFF1F2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [marun, Color(0xFFB76E79)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.groups_rounded,
                              color: Colors.white, size: 34),
                          SizedBox(height: 12),
                          Text(
                            'Daftar Pengguna',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelola data pengguna dengan mudah',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Semua User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: marun,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<UserModel>>(
                      future: usersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cloud_off_outlined,
                                      size: 48, color: marun),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Data gagal dimuat',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _cleanError(snapshot.error!),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton(
                                    onPressed: refreshUsers,
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final users = snapshot.data ?? [];
                        if (users.isEmpty) {
                          return const Center(
                            child: Text('Belum ada data user.'),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFF0D9DC),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 27,
                                  backgroundColor: marunMuda,
                                  backgroundImage: user.avatar.isNotEmpty
                                      ? NetworkImage(user.avatar)
                                      : null,
                                  child: user.avatar.isEmpty
                                      ? const Icon(Icons.person, color: marun)
                                      : null,
                                ),
                                title: Text(
                                  user.fullName.isEmpty
                                      ? 'User ${user.id}'
                                      : user.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    user.email,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      openForm(user: user);
                                    } else if (value == 'delete') {
                                      removeUser(user);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Hapus'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormResult {
  final UserModel? user;
  final int? deletedId;
  final String message;

  const _FormResult({
    this.user,
    this.deletedId,
    required this.message,
  });
}

class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final UserService service;

  const UserFormDialog({
    super.key,
    required this.user,
    required this.service,
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(
      text: user == null ? '' : user.fullName,
    );
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  List<String> _splitName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return [parts.first, ''];
    return [parts.first, parts.skip(1).join(' ')];
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    try {
      final oldUser = widget.user;
      final response = oldUser == null
          ? await widget.service.createUser(name, email)
          : await widget.service.updateUser(oldUser.id, name, email);

      final parts = _splitName(name);
      final rawId = response['id'];
      final newId = rawId is int
          ? rawId
          : int.tryParse('$rawId') ?? oldUser?.id ?? DateTime.now().millisecondsSinceEpoch;

      final savedUser = UserModel(
        id: newId,
        email: email,
        firstName: parts[0],
        lastName: parts[1],
        avatar: oldUser?.avatar ?? '',
      );

      if (!mounted) return;
      Navigator.of(context).pop(
        _FormResult(
          user: savedUser,
          message: oldUser == null
              ? 'User berhasil dikirim dan ditampilkan.'
              : 'Perubahan user berhasil dikirim.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        widget.user == null ? 'Tambah User' : 'Edit User',
        style: const TextStyle(color: marun, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nama lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _loading ? null : _save,
          icon: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_loading ? 'Menyimpan...' : 'Simpan'),
        ),
      ],
    );
  }
}

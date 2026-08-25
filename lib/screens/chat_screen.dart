import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapato/groq_config.dart';
import 'package:mapato/l10n/app_localizations.dart';
import 'package:mapato/native.dart';
import 'package:mapato/state/app_state.dart';
import 'package:mapato/theme.dart';
import 'package:mapato/utils.dart';
import 'package:provider/provider.dart';

const _groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';

const List<String> _groqModels = [
  'openai/gpt-oss-120b',
  'openai/gpt-oss-20b',
  'qwen/qwen3.6-27b',
];

class _Msg {
  final String role; // 'user' | 'assistant'
  final String text;
  _Msg(this.role, this.text);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<_Msg> _messages = [];
  bool _busy = false;
  String? _error;

  // Conversation history persisted on-device.
  List<Map<String, dynamic>> _conversations = [];
  String _activeId = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await getPrefString('ai_conversations');
    if (raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _conversations = list.cast<Map<String, dynamic>>();
      } catch (_) {
        _conversations = [];
      }
    }
    if (_conversations.isNotEmpty) {
      _openConversation(_conversations.first['id'] as String);
    }
    if (mounted) setState(() {});
  }

  Future<String> _apiKey() async {
    final k = await getPrefString('groq_api_key');
    return k.isNotEmpty ? k : await getNativeApiKey();
  }

  Future<String> _model() async =>
      (await getPrefString('groq_model')).isEmpty ? _groqModels.first : await getPrefString('groq_model');

  String _buildContext() {
    final txns = context.read<AppState>().transactions;
    final now = DateTime.now();
    final monthTxns = txns.where((t) =>
        t.timestamp.year == now.year && t.timestamp.month == now.month).toList();
    double income = 0, expense = 0, saved = 0;
    for (final t in monthTxns) {
      if (t.direction == 'in') income += t.amount;
      else if (t.direction == 'out') expense += t.amount;
      else if (t.direction == 'transfer') saved += t.amount;
    }
    final cats = <String, double>{};
    for (final t in monthTxns) {
      if (t.direction == 'out') {
        cats[t.category] = (cats[t.category] ?? 0) + t.amount;
      }
    }
    final top = cats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topStr = top.take(3).map((e) => '${e.key} ${tzs(e.value)}').join(', ');
    return 'User financial summary (this month, Tsh): '
        'income ${tzs(income)}, expenses ${tzs(expense)}, saved ${tzs(saved)}. '
        'Top spending categories: ${topStr.isEmpty ? 'none' : topStr}. '
        'Currency is Tanzanian Shillings (Tsh). Networks: M-Pesa, Mixx by Yas, '
        'Airtel Money, HaloPesa, AzamPesa.';
  }

  /// Produces clean plain-text replies: drops thinking-model <think> blocks and
  /// removes the markdown decorations (asterisks, hashes, backticks) the user
  /// asked to avoid.
  String _cleanReply(String s) {
    s = s.replaceAll(RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false), '');
    s = s.replaceAll('**', '').replaceAll('*', '').replaceAll('#', '').replaceAll('`', '');
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return s;
  }

  String _titleFromMessages() {
    final firstUser = _messages.where((m) => m.role == 'user').firstOrNull;
    final t = firstUser?.text ?? '';
    if (t.isEmpty) return 'New chat';
    return t.length > 30 ? '${t.substring(0, 30)}â€¦' : t;
  }

  Future<void> _persist() async {
    if (_messages.isEmpty) return;
    final maps = _messages.map((m) => {'role': m.role, 'text': m.text}).toList();
    if (_activeId.isEmpty) {
      _activeId = DateTime.now().microsecondsSinceEpoch.toString();
    }
    final idx = _conversations.indexWhere((c) => c['id'] == _activeId);
    final entry = {'id': _activeId, 'title': _titleFromMessages(), 'messages': maps};
    if (idx == -1) {
      _conversations.insert(0, entry);
    } else {
      _conversations.removeAt(idx);
      _conversations.insert(0, entry);
    }
    await setPrefString('ai_conversations', jsonEncode(_conversations));
    if (mounted) setState(() {});
  }

  void _openConversation(String id) {
    final conv = _conversations.firstWhere(
      (c) => c['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    if (conv.isEmpty) return;
    _activeId = id;
    final msgs = (conv['messages'] as List?) ?? [];
    _messages.clear();
    for (final m in msgs.cast<Map<String, dynamic>>()) {
      _messages.add(_Msg(m['role'] as String, m['text'] as String));
    }
    if (mounted) setState(() {});
  }

  void _newChat() {
    _activeId = '';
    _messages.clear();
    _error = null;
    if (mounted) setState(() {});
  }

  void _deleteConversation(String id) {
    _conversations.removeWhere((c) => c['id'] == id);
    setPrefString('ai_conversations', jsonEncode(_conversations));
    if (_activeId == id) _newChat();
    if (mounted) setState(() {});
  }

  Future<void> _send() async {
    final s = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    final key = await _apiKey();
    if (key.isEmpty) {
      setState(() => _error = s.aiUnavailable);
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
      _messages.add(_Msg('user', text));
      _controller.clear();
    });
    _scrollToEnd();

    final system = _systemPrompt();
    try {
      final reply = await _groqChat(key, await _model(), system, text);
      setState(() => _messages.add(_Msg('assistant', _cleanReply(reply))));
      await _persist();
    } catch (e) {
      setState(() =>
          _error = s.couldNotReachAi);
    } finally {
      setState(() => _busy = false);
      _scrollToEnd();
    }
  }

  String _systemPrompt() => '''
You are Mapato AI, the built-in assistant inside Mapato, a Tanzanian app that
tracks mobile money (M-Pesa, Mixx by Yas, Airtel Money, HaloPesa, AzamPesa).

Rules:
- Reply briefly and in plain language. Give only the essentials, no long
  explanations.
- Plain text only: no asterisks, hashtags, or markdown. Use a 1. 2. 3. list
  only when it genuinely helps.
- You are NOT a licensed financial advisor. For big money decisions, suggest
  seeing one.
- Never ask for or store the user's PIN, OTP, password, or card number.
- Mobile-money scams are common in Tanzania: warn if anyone asks for a
  PIN/OTP, a USSD code, or promises "hibitishi"/cash-back. Mapato never asks
  for a PIN.
- You only see a monthly SUMMARY of the user's money, never individual
  transactions. If you don't know a specific past transaction, say so.
- Match the user's language (English or Swahili). Use Tsh.

Summary you may use:
${_buildContext()}
''';

  Future<String> _groqChat(
      String key, String model, String system, String userText) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(Uri.parse(_groqEndpoint));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $key');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final body = jsonEncode({
        'model': model,
        'temperature': 0.3,
        'max_tokens': 1200,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': userText},
        ],
      });
      req.write(body);
      final resp = await req.close();
      final raw = await resp.transform(utf8.decoder).join();
      if (resp.statusCode != 200) {
        throw 'HTTP ${resp.statusCode}: $raw';
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>;
      return choices.first['message']['content'] as String;
    } finally {
      client.close();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(s.chatHistory,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.add_comment_outlined),
                title: Text(s.newChat),
                onTap: () {
                  Navigator.pop(context);
                  _newChat();
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (ctx, i) {
                    final conv = _conversations[i];
                    final id = conv['id'] as String;
                    final title = (conv['title'] as String?) ?? 'Chat';
                    return ListTile(
                      selected: id == _activeId,
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        Navigator.pop(context);
                        _openConversation(id);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => _deleteConversation(id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: s.history,
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(s.mapatoAi),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: s.newChat,
            onPressed: _newChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Text(
                        s.askAboutMoney,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(14),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final m = _messages[i];
                      final isUser = m.role == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.82),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary : cs.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: isUser
                                ? null
                                : Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            m.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : cs.onSurface,
                              height: 1.35,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(_error!,
                  style: TextStyle(color: AppColors.expense, fontSize: 12.5)),
            ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: s.askHint,
                        prefixIcon: const Icon(Icons.chat_bubble_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.send_rounded),
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

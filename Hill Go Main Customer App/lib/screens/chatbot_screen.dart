import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });

  final String text;
  final bool isUser;
  final bool isTyping;
}

/// In-app HillGo assistant tab — UI + lightweight demo replies.
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  static const String routeName = '/chatbot';

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Hi! I\'m HillGo Assistant. Ask me about rides, food, parcels, market, or your wallet.',
      isUser: false,
    ),
  ];
  bool _sending = false;

  static const _suggestions = [
    'Book a ride',
    'Order food',
    'Track my parcel',
    'Wallet balance',
    'Nearby offers',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  String _replyFor(String input) {
    final q = input.toLowerCase();
    if (q.contains('ride') || q.contains('taxi') || q.contains('driver')) {
      return 'To book a ride, open Ride from Home, set pickup & drop, then pick a vehicle. Need help with fares or tracking?';
    }
    if (q.contains('food') || q.contains('restaurant') || q.contains('hungry')) {
      return 'Hungry? Tap Food on Home to browse nearby restaurants, add items to cart, and checkout. I can also tip you toward popular spots.';
    }
    if (q.contains('parcel') || q.contains('package') || q.contains('delivery')) {
      return 'For parcels, open Parcel → choose type → enter pickup & receiver details. You can track shipments from Profile → Parcels.';
    }
    if (q.contains('wallet') || q.contains('balance') || q.contains('payment')) {
      return 'Your Hill Wallet lives under Profile → Hill Wallet. You can check balance, add money, and review transactions there.';
    }
    if (q.contains('market') || q.contains('shop') || q.contains('product')) {
      return 'Browse Market from Home or the Market tab for groceries, gadgets, and more. Add items to cart when you\'re ready.';
    }
    if (q.contains('offer') || q.contains('promo') || q.contains('voucher')) {
      return 'Check Nearby Offers on Home, or open Rewards from Profile for vouchers and loyalty perks.';
    }
    if (q.contains('hello') || q.contains('hi') || q.contains('hey')) {
      return 'Hey there! How can I help you get around Bandarban today — ride, food, parcel, or shopping?';
    }
    if (q.contains('help') || q.contains('support')) {
      return 'I can guide you through Ride, Food, Parcel, Market, Wallet, and Rewards. Try a quick chip below or type your question.';
    }
    return 'Got it. Try asking about booking a ride, ordering food, sending a parcel, shopping the market, or checking your wallet.';
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(const _ChatMessage(text: '', isUser: false, isTyping: true));
      _controller.clear();
    });
    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final reply = _replyFor(text);
    setState(() {
      _messages.removeWhere((m) => m.isTyping);
      _messages.add(_ChatMessage(text: reply, isUser: false));
      _sending = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      children: [
        _ChatHeader(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _MessageBubble(message: _messages[index]);
            },
          ),
        ),
        if (_messages.length <= 2)
          _SuggestionChips(
            suggestions: _suggestions,
            onTap: _send,
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomInset),
          child: _Composer(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_sending,
            onSend: () => _send(_controller.text),
          ),
        ),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryNavy, AppColors.accentBlue],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HillGo Assistant',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
                    SizedBox(width: 6),
                    Text(
                      'Online · usually replies instantly',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isUser ? AppColors.primaryNavy : AppColors.white;
    final fg = isUser ? AppColors.white : AppColors.textPrimary;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: message.isTyping
            ? const _TypingDots()
            : Text(
                message.text,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value + i * 0.2) % 1.0;
            final opacity = 0.35 + 0.65 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 5),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({
    required this.suggestions,
    required this.onTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = suggestions[index];
          return GestureDetector(
            onTap: () => onTap(label),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentBlueSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Ask HillGo anything…',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
            ),
          ),
          Material(
            color: enabled ? AppColors.accentOrange : AppColors.textMuted,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onSend : null,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.send_rounded, color: AppColors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

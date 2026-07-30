import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/store_model.dart';
import '../../providers/store_provider.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common_widgets.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<StoreProvider>();
      if (s.reviews.isEmpty) s.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final reviews = store.filteredReviews;
    final all = store.reviews;
    final avg = all.isEmpty
        ? 0.0
        : all.fold<double>(0, (s, r) => s + r.rating) / all.length;

    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in all) {
      final star = r.rating.round().clamp(1, 5);
      dist[star] = (dist[star] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('HillGo Vendor', style: AppTextStyles.brand),
      ),
      body: store.isLoading && all.isEmpty
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Store Reviews', style: AppTextStyles.h1),
                const SizedBox(height: 12),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            avg.toStringAsFixed(1),
                            style: AppTextStyles.h1
                                .copyWith(color: AppColors.primary),
                          ),
                          const StarRating(rating: 4.8),
                          Text(
                            'Based on ${NumberFormat('#,###').format(all.isEmpty ? 1284 : all.length * 321)} reviews',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rating Distribution',
                                style: AppTextStyles.bodyBold),
                            const SizedBox(height: 8),
                            ...[5, 4, 3, 2, 1].map((star) {
                              final count = dist[star] ?? 0;
                              final pct = all.isEmpty
                                  ? [0.82, 0.12, 0.04, 0.01, 0.01][5 - star]
                                  : count / all.length;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text('$star', style: AppTextStyles.caption),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: pct,
                                          minHeight: 8,
                                          backgroundColor:
                                              const Color(0xFFEEEEEE),
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${(pct * 100).round()}%',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                FilterChipBar(
                  items: const ['All Reviews', 'Unreplied', 'Positive'],
                  selected: store.reviewFilter,
                  onSelected: store.setReviewFilter,
                ),
                const SizedBox(height: 12),
                if (reviews.isEmpty)
                  const EmptyView(message: 'No reviews in this filter.')
                else
                  ...reviews.map((r) => _ReviewCard(review: r)),
              ],
            ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ReviewModel review;

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes} minutes ago';
    if (d.inHours < 24) return '${d.inHours} hours ago';
    return '${d.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(review.avatarUrl),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.customerName, style: AppTextStyles.bodyBold),
                      Text(_timeAgo(review.createdAt),
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                if (review.isVerified)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.verified,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Verified Purchase',
                      style: AppTextStyles.caption
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            StarRating(rating: review.rating),
            const SizedBox(height: 6),
            Text(review.comment, style: AppTextStyles.body),
            if (review.hasReply) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Store Response', style: AppTextStyles.bodyBold),
                    if (review.repliedAt != null)
                      Text(
                        DateFormat('MMM d, h:mm a').format(review.repliedAt!),
                        style: AppTextStyles.caption,
                      ),
                    Text(
                      review.reply!,
                      style: AppTextStyles.body
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    context.push('/store/reviews/${review.id}/reply'),
                icon: Icon(
                  review.hasReply ? Icons.edit_outlined : Icons.reply,
                  size: 18,
                  color: AppColors.primary,
                ),
                label: Text(
                  review.hasReply ? 'Edit Reply' : 'Reply',
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReplyReviewScreen extends StatefulWidget {
  const ReplyReviewScreen({super.key, required this.reviewId});

  final String reviewId;

  @override
  State<ReplyReviewScreen> createState() => _ReplyReviewScreenState();
}

class _ReplyReviewScreenState extends State<ReplyReviewScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final r = context.read<StoreProvider>().findReview(widget.reviewId);
      if (r?.reply != null) {
        _ctrl.text = r!.reply!;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<StoreProvider>();
    final review = store.findReview(widget.reviewId);

    if (review == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reply')),
        body: const ErrorView(message: 'Review not found'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Reply to Review', style: AppTextStyles.brand),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(review.avatarUrl),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(review.avatarUrl),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.customerName,
                              style: AppTextStyles.bodyBold),
                          Text(
                            'VERIFIED PURCHASE • 2 HOURS AGO',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(review.comment, style: AppTextStyles.serifQuote),
                if (review.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: review.imageUrls
                        .map(
                          (u) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: NetworkThumb(url: u, size: 56),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.reply, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Your Response',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            maxLength: 500,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Write your response to ${review.customerName.split(' ').first}...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Professionalism',
                          style: AppTextStyles.bodyBold
                              .copyWith(color: AppColors.primary)),
                      Text(
                        'Keep it polite and appreciative. A simple \'Thank you\' goes a long way in building loyalty.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personalization', style: AppTextStyles.bodyBold),
                      Text(
                        'Address specific points mentioned in the review to show you truly care about feedback.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Post Reply',
                  icon: Icons.send,
                  loading: store.isSaving,
                  onPressed: _ctrl.text.trim().isEmpty
                      ? null
                      : () async {
                          final ok = await store.replyToReview(
                            widget.reviewId,
                            _ctrl.text.trim(),
                          );
                          if (context.mounted && ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reply posted')),
                            );
                            context.pop();
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

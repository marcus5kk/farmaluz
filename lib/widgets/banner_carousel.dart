import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/banner_item.dart';
import '../config/app_config.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _current = 0;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) _autoPlay();
  }

  void _autoPlay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      final next = (_current + 1) % widget.banners.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      _autoPlay();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final corPrimaria = Color(int.parse(AppConfig.corPrimaria.replaceAll('#', '0xFF')));

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              final banner = widget.banners[i];
              return GestureDetector(
                onTap: () async {
                  if (banner.link != null && banner.link!.isNotEmpty) {
                    final uri = Uri.tryParse(banner.link!);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: banner.imagemUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey[200]),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          AnimatedSmoothIndicator(
            activeIndex: _current,
            count: widget.banners.length,
            effect: WormEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: corPrimaria,
              dotColor: corPrimaria.withOpacity(0.25),
            ),
          ),
        ],
      ],
    );
  }
}

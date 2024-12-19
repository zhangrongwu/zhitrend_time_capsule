import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../domain/models/media_item.dart';

class CapsuleMediaGallery extends StatefulWidget {
  final List<MediaItem> media;
  final int initialIndex;

  const CapsuleMediaGallery({
    Key? key,
    required this.media,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _CapsuleMediaGalleryState createState() => _CapsuleMediaGalleryState();
}

class _CapsuleMediaGalleryState extends State<CapsuleMediaGallery> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _showFullScreenGallery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          media: widget.media,
          initialIndex: _currentIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.media.length,
        itemBuilder: (context, index) {
          final mediaItem = widget.media[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
                _showFullScreenGallery(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMediaThumbnail(mediaItem),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaThumbnail(MediaItem mediaItem) {
    switch (mediaItem.type) {
      case MediaType.image:
        return _buildImageThumbnail(mediaItem);
      case MediaType.video:
        return _buildVideoThumbnail(mediaItem);
      case MediaType.audio:
        return _buildAudioThumbnail(mediaItem);
      default:
        return _buildDefaultThumbnail();
    }
  }

  Widget _buildImageThumbnail(MediaItem mediaItem) {
    return mediaItem.localPath != null
        ? Image.file(
            File(mediaItem.localPath!),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          )
        : Image.network(
            mediaItem.url!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          );
  }

  Widget _buildVideoThumbnail(MediaItem mediaItem) {
    return Stack(
      alignment: Alignment.center,
      children: [
        mediaItem.thumbnailPath != null
            ? Image.file(
                File(mediaItem.thumbnailPath!),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              )
            : Image.network(
                mediaItem.thumbnailUrl ?? '',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
        const CircleAvatar(
          backgroundColor: Colors.black54,
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioThumbnail(MediaItem mediaItem) {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 80,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.file_present,
          size: 80,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<MediaItem> media;
  final int initialIndex;

  const FullScreenGallery({
    Key? key,
    required this.media,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenGalleryState createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.media.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final mediaItem = widget.media[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: mediaItem.localPath != null
                ? FileImage(File(mediaItem.localPath!))
                : NetworkImage(mediaItem.url!) as ImageProvider,
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.5,
            maxScale: PhotoViewComputedScale.covered * 1.5,
            heroAttributes: PhotoViewHeroAttributes(tag: mediaItem.id),
          );
        },
        itemCount: widget.media.length,
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

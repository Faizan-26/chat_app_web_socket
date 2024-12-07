import 'package:cloudinary_public/cloudinary_public.dart';


class CloudinaryService {

  final CloudinaryPublic cloudinary =
      CloudinaryPublic('drjns19ay', 'cnrpject', cache: true);

  Future<String?> uploadImage(String groupId, String imagePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath,
            publicId: groupId, resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

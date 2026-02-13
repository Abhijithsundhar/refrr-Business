import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:refrr_admin/core/constants/firebase_constants.dart';
import 'package:refrr_admin/models/category_model.dart';


class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reference to the category collection
  CollectionReference get _categoryCollection =>
      _firestore.collection(FirebaseCollections.categoryCollection);

  /// Add a new category
  Future<CategoryModel?> addCategory(CategoryModel category) async {
    try {
      final docRef = await _categoryCollection.add(category.toMap());
      await docRef.update({'documentId': docRef.id});

      return category.copyWith(documentId: docRef.id, reference: docRef);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all categories
  Future<List<CategoryModel>> fetchCategories(String? id) async {
    try {
      final snapshot = await _categoryCollection.get();

      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(
          doc.data() as Map<String, dynamic>,
          ref: doc.reference,
        ).copyWith(documentId: doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update category
  Future<void> updateCategory(CategoryModel category) async {
    try {
      if (category.documentId != null) {
        await _categoryCollection
            .doc(category.documentId)
            .update(category.toMap());
      } else if (category.reference != null) {
        await category.reference!.update(category.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete category
  Future<void> deleteCategory(CategoryModel category) async {
    try {
      if (category.documentId != null) {
        await _categoryCollection.doc(category.documentId).delete();
      } else if (category.reference != null) {
        await category.reference!.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // --------------------------------------------------------
  // ✅ NEW FUNCTION: fetch only selected categories by IDs
  // --------------------------------------------------------
  Future<List<CategoryModel>> fetchCategoriesByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];

      final snapshot = await _categoryCollection
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(
          doc.data() as Map<String, dynamic>,
          ref: doc.reference,
        ).copyWith(documentId: doc.id);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}

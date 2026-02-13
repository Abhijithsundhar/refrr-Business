// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:refrr_admin/core/common/custom-appBar.dart';
// import 'package:refrr_admin/core/common/custom-text-field.dart';
// import 'package:refrr_admin/core/common/global_variables.dart';
// import 'package:refrr_admin/core/common/loader.dart';
// import 'package:refrr_admin/core/common/text_editing_controllers.dart';
// import 'package:refrr_admin/core/constants/textfield-space.dart';
// import 'package:refrr_admin/feature/pipeline/controller/country-controllor.dart' hide selectedCountryProvider;
// import 'package:refrr_admin/feature/pipeline/controller/industry-controler.dart';
// import 'package:refrr_admin/models/country-model.dart';
// import 'package:refrr_admin/models/leads_model.dart';
// import 'package:cached_network_image/cached_network_image.dart';
//
// class EditProfile extends ConsumerStatefulWidget {
//   final LeadsModel? currentFirm;
//   const EditProfile({super.key, required this.currentFirm});
//
//   @override
//   ConsumerState<EditProfile> createState() => _EditProfileState();
// }
//
// class _EditProfileState extends ConsumerState<EditProfile> {
//   @override
//   void initState() {
//     super.initState();
//     // preload firm data into controllers
//     leadsContactNoController.text = widget.currentFirm?.contactNo ?? '';
//     leadsNameController.text = widget.currentFirm?.name ?? '';
//     leadsIndustryController.text = widget.currentFirm?.industry ?? '';
//     leadsZoneController.text = widget.currentFirm?.zone ?? '';
//     leadsCurrencyController.text = widget.currentFirm?.currency ?? '';
//     leadsWebsiteController.text = widget.currentFirm?.website ?? '';
//     leadsEmailController.text = widget.currentFirm?.mail ?? '';
//     leadsAddressController.text = widget.currentFirm?.address ?? '';
//     leadsAboutController.text = widget.currentFirm?.aboutFirm ?? '';
//     leadsCountryController.text = widget.currentFirm?.country ?? '';
//   }
// CountryModel? selectedCountry;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar(title: 'Edit Profile'),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         child: buildSection(children: [
//           // ---------- LOGO IMAGE ----------
//           SizedBox(
//             width: width * 0.45,
//             height: width * 0.25,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: CachedNetworkImage(
//                 imageUrl: widget.currentFirm?.logo ?? '',
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) =>
//                 const Center(child: CommonLoader()),
//                 errorWidget: (context, url, error) =>
//                 const Icon(Icons.broken_image, color: Colors.grey),
//               ),
//             ),
//           ),
//
//           // ---------- NAME ----------
//           inputField('Name', leadsNameController, TextInputType.text,
//               const SizedBox()),
//
//           // ---------- INDUSTRY ----------
//           Consumer(
//             builder: (context, ref, _) {
//               final industriesAsync = ref.watch(
//                 industryStreamProvider(
//                     widget.currentFirm?.reference?.id ?? ''),
//               );
//
//               return industriesAsync.when(
//                 data: (industries) {
//                   final List<String> allIndustries =
//                   industries.map((e) => e.name.toString()).toList();
//
//                   return GestureDetector(
//                     onTap: () async {
//                       final selected = await _showSearchSheet<String>(
//                         context: context,
//                         title: 'industry',
//                         data: allIndustries,
//                       );
//
//                       if (selected != null && selected.isNotEmpty) {
//                         setState(() {
//                           leadsIndustryController.text = selected;
//                         });
//                       }
//                     },
//                     child: AbsorbPointer(
//                       child: inputField(
//                         'Industry',
//                         leadsIndustryController,
//                         TextInputType.text,
//                         const Icon(Icons.keyboard_arrow_down_rounded),
//                         readOnly: true,
//                       ),
//                     ),
//                   );
//                 },
//                 loading: () => inputField(
//                   'Industry',
//                   leadsIndustryController,
//                   TextInputType.text,
//                   const SizedBox(),
//                   readOnly: true,
//                 ),
//                 error: (e, _) => inputField(
//                   'Industry',
//                   leadsIndustryController,
//                   TextInputType.text,
//                   const SizedBox(),
//                   readOnly: true,
//                 ),
//               );
//             },
//           ),
//
//           // ---------- COUNTRY ----------
//           Consumer(builder: (context, ref, _) {
//             final countriesAsync = ref.watch(countriesFutureProvider);
//             return countriesAsync.when(
//               data: (countries) {
//                 return GestureDetector(
//                   onTap: () async {
//                     final selectedCountry =
//                     await _showSearchSheet<CountryModel>(
//                       context: context,
//                       title: 'country',
//                       data: countries,
//                       labelBuilder: (c) => c.countryName,
//                       onSearch: (q) => countries
//                           .where((c) => c.countryName
//                           .toLowerCase()
//                           .contains(q.toLowerCase()))
//                           .toList(),
//                     );
//
//                     if (selectedCountry != null) {
//                       // save to provider
//                       ref
//                           .read(selectedCountryProvider.notifier)
//                           .state = selectedCountry as String;
//                       // update text fields
//                       leadsCountryController.text =
//                           selectedCountry.countryName;
//                       leadsCurrencyController.text =
//                           selectedCountry.currency;
//                     }
//                   },
//                   child: AbsorbPointer(
//                     child: inputField(
//                       'Country',
//                       leadsCountryController,
//                       TextInputType.text,
//                       const Icon(Icons.keyboard_arrow_down_rounded),
//                       readOnly: true,
//                     ),
//                   ),
//                 );
//               },
//               loading: () => inputField(
//                   'Country',
//                   leadsCountryController,
//                   TextInputType.text,
//                   const SizedBox(),
//                   readOnly: true),
//               error: (e, _) => inputField(
//                   'Country',
//                   leadsCountryController,
//                   TextInputType.text,
//                   const SizedBox(),
//                   readOnly: true),
//             );
//           }),
//
//           // ---------- ZONE (depends on selected country) ----------
//           Consumer(
//             builder: (context, ref, _) {
//               final CountryModel? selectedCountry =
//               ref.watch(selectedCountryProvider as ProviderListenable<CountryModel?>);
//               final countryDocId = selectedCountry?.documentId ?? '';
//
//               if (countryDocId.isEmpty) {
//                 return inputField(
//                   'Zone',
//                   leadsZoneController,
//                   TextInputType.text,
//                   const Icon(Icons.keyboard_arrow_down_rounded),
//                   readOnly: true,
//                 );
//               }
//
//               final zonesAsync = ref.watch(citiesFutureProvider(countryDocId));
//               return zonesAsync.when(
//                 data: (zones) {
//                   final allZones = zones.map((c) => c.zone).toList();
//                   return GestureDetector(
//                     onTap: () async {
//                       final selected = await _showSearchSheet<String>(
//                         context: context,
//                         title: 'zone',
//                         data: allZones,
//                       );
//
//                       if (selected != null && selected.isNotEmpty) {
//                         setState(() => leadsZoneController.text = selected);
//                       }
//                     },
//                     child: AbsorbPointer(
//                       child: inputField(
//                         'Zone',
//                         leadsZoneController,
//                         TextInputType.text,
//                         const Icon(Icons.keyboard_arrow_down_rounded),
//                         readOnly: true,
//                       ),
//                     ),
//                   );
//                 },
//                 loading: () => inputField(
//                     'Zone',
//                     leadsZoneController,
//                     TextInputType.text,
//                     const SizedBox(),
//                     readOnly: true),
//                 error: (_, __) => inputField(
//                     'Zone',
//                     leadsZoneController,
//                     TextInputType.text,
//                     const SizedBox(),
//                     readOnly: true),
//               );
//             },
//           ),
//
//           // ---------- CURRENCY TYPE (auto‑filled on country select) ----------
//           inputField(
//             'Currency Type',
//             leadsCurrencyController,
//             TextInputType.text,
//             const SizedBox(),
//             readOnly: true,
//           ),
//
//           // ---------- WEBSITE ----------
//           inputField('Website', leadsWebsiteController, TextInputType.text,
//               const SizedBox()),
//
//           // ---------- PHONE ----------
//           inputField('Phone', leadsContactNoController, TextInputType.number,
//               const SizedBox()),
//
//           // ---------- EMAIL ----------
//           inputField('E‑mail', leadsEmailController,
//               TextInputType.emailAddress, const SizedBox()),
//
//           // ---------- ADDRESS ----------
//           inputField('Address', leadsAddressController, TextInputType.text,
//               const SizedBox(),
//               maxLines: 2),
//
//           // ---------- ABOUT ----------
//           inputField('About', leadsAboutController, TextInputType.text,
//               const SizedBox(),
//               maxLines: 3),
//
//           // ---------- UPDATE BUTTON ----------
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {},
//               child: Text(
//                 'Update',
//                 style: GoogleFonts.dmSans(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   /// ---------- SEARCHABLE BOTTOM SHEET ----------
//   Future<T?> _showSearchSheet<T>({
//     required BuildContext context,
//     required String title,
//     required List<T> data,
//     String Function(T)? labelBuilder,
//     List<T> Function(String)? onSearch,
//   }) {
//     final TextEditingController searchCtrl = TextEditingController();
//     final ValueNotifier<List<T>> filtered = ValueNotifier<List<T>>(data);
//
//     return showModalBottomSheet<T>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (ctx) {
//         return Padding(
//           padding:
//           EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
//           child: Container(
//             color: Colors.white,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(height: 12),
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   child: TextField(
//                     controller: searchCtrl,
//                     decoration: InputDecoration(
//                       hintText: 'Search $title...',
//                       prefixIcon:
//                       const Icon(Icons.search, color: Colors.grey),
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 14),
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onChanged: (val) {
//                       final query = val.toLowerCase();
//                       filtered.value = onSearch != null
//                           ? onSearch(query)
//                           : data
//                           .where((e) => (labelBuilder != null
//                           ? labelBuilder(e)
//                           : e.toString())
//                           .toLowerCase()
//                           .contains(query))
//                           .toList();
//                     },
//                   ),
//                 ),
//                 Flexible(
//                   child: ValueListenableBuilder<List<T>>(
//                     valueListenable: filtered,
//                     builder: (context, list, _) {
//                       if (list.isEmpty) {
//                         return const Padding(
//                           padding: EdgeInsets.all(24.0),
//                           child: Text("No results found"),
//                         );
//                       }
//                       return ListView.separated(
//                         shrinkWrap: true,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8, horizontal: 20),
//                         itemCount: list.length,
//                         separatorBuilder: (_, __) => Divider(
//                           color: Colors.grey.shade200,
//                           height: 1,
//                         ),
//                         itemBuilder: (_, index) {
//                           final item = list[index];
//                           final label = labelBuilder != null
//                               ? labelBuilder(item)
//                               : item.toString();
//                           return ListTile(
//                             title: Text(
//                               label,
//                               style: const TextStyle(
//                                   fontSize: 15,
//                                   fontWeight: FontWeight.w500),
//                             ),
//                             onTap: () => Navigator.pop(ctx, item),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:refrr_admin/core/common/chat_screen_support_functions.dart';
import 'package:refrr_admin/core/functions/status_reqeust_accept_function.dart';
import 'package:refrr_admin/core/utils/date_format.dart';
import 'package:refrr_admin/core/utils/shedule_messages.dart';
import 'package:refrr_admin/models/chatbox_model.dart';

///chat data define here
Widget chatItem({
  required ChatModel msg,
  required String currentUserId,
  Function(ChatModel)? onAcceptTransaction,
  Function(ChatModel)? onRejectTransaction,
  Function(ChatModel)? onAcceptStatus,
  Function(ChatModel)? onRejectStatus,
}) {
  switch (msg.type) {
    case "simple":
      return simpleMessage(
        msg.message ?? "",
        formatDateTime(msg.time ?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );

    case "status":
      debugPrint('📌 STATUS - requiresAction: ${msg.requiresAction}, transactionStatus: "${msg.transactionStatus}"');

      // ✅ Show statusMessageWithActions if:
      // 1. requiresAction is true, OR
      // 2. transactionStatus has a value (to show accepted/rejected badge)
      final bool isStatusRequest = msg.requiresAction == true;
      final bool hasStatus = msg.transactionStatus?.isNotEmpty == true;

      if (isStatusRequest || hasStatus) {
        return statusMessageWithActions(
          message: msg.message ?? "",
          time: formatDateTime(msg.time ?? DateTime.now(), showDate: false),
          bgImage: msg.imageUrl ?? "",
          transactionStatus: msg.transactionStatus ?? '',
          description :msg.description ??'',
          onAccept: () {
            debugPrint('🟢 Accept status tapped!');
            if (onAcceptStatus != null) onAcceptStatus(msg);
          },
          onReject: () {
            debugPrint('🔴 Reject status tapped!');
            if (onRejectStatus != null) onRejectStatus(msg);
          },
        );
      } else {
        return simpleMessage(
          msg.message ?? "",
          formatDateTime(msg.time ?? DateTime.now(), showDate: false),
          msg.imageUrl ?? "",
        );
      }

    case "transaction":
      debugPrint('📌 TRANSACTION - requiresAction: ${msg.requiresAction}, transactionStatus: "${msg.transactionStatus}"');

      final bool isTransactionRequest = msg.requiresAction == true;
      final bool hasTransactionStatus = msg.transactionStatus?.isNotEmpty == true;

      if (isTransactionRequest || hasTransactionStatus) {
        return transactionsMessageWithActions(
          amount: msg.amount.toString(),
          message: msg.message ?? "",
          description: msg.description ?? "",
          time: formatDateTime(msg.time ?? DateTime.now(), showDate: false),
          bgImage: msg.imageUrl ?? '',
          onAccept: () {
            debugPrint('🟢 Accept transaction tapped!');
            if (onAcceptTransaction != null) onAcceptTransaction(msg);
          },
          onReject: () {
            debugPrint('🔴 Reject transaction tapped!');
            if (onRejectTransaction != null) onRejectTransaction(msg);
          },
          transactionStatus: msg.transactionStatus ?? '',
        );
      } else {
        return transactionMessage(
          amount: msg.amount.toString(),
          message: msg.message ?? "",
          description: msg.description ?? "",
          time: formatDateTime(msg.time ?? DateTime.now(), showDate: false),
          bgImage: msg.imageUrl ?? '',
        );
      }

    case "sales":
      return simpleMessage(
        msg.message ?? "",
        formatDateTime(msg.time ?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );

    case "schedule":
      return simpleMessage(
        getMessageText(msg.message, msg.time.toString(), msg.description) ?? "",
        formatDateTime(msg.dateLabel ?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );

    case "type":
      return simpleMessage(
        msg.message ?? "",
        formatDateTime(msg.time ?? DateTime.now(), showDate: false),
        msg.imageUrl ?? "",
      );

    default:
      return const SizedBox.shrink();
  }
}
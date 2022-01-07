import 'package:authentication/authentication.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:data_access/data_access.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/widgets/custom_web_view.dart';

const _paymentSuccessfullUrl = "success.url";
const _paymentCancelledUrl = "cancel.url";

class Payment {
  final FirebaseFunctions functions;

  Payment({FirebaseFunctions? firebaseFunctions})
      : functions = firebaseFunctions ?? FirebaseFunctions.instance;

  Future<TokenPaymenResponse> makeTokenPayment(
    double amount,
    String userId,
    String token,
  ) async {
    try {
      final response = await functions.httpsCallable("makeTokenPayment").call({
        "token": token,
        "payment": {"payer_id": userId, "amount": amount}
      });
      return TokenPaymenResponse(
        response.data["status"] ?? "failed",
        paymentData: {"id": response.data["payment_id"]},
      );
    } on FirebaseFunctionsException catch (e) {
      if (e.code == "unable_to_create_payment") {
        return TokenPaymenResponse(
          // partial status means the payment have been successfully made but create the payment entry into our db failed.
          "partial",
          paymentData: {
            "payer_id": userId,
            "amount": amount,
            "payment_type": "CARD",
            ...e.details
          },
        );
      } else {
        return const TokenPaymenResponse("failed");
      }
    }
  }

  Future<bool> authorizeTokenPayment(
    Account account,
    BuildContext context, [
    double initialPaymenAmount = 0,
  ]) async {
    final paymentUrl = await functions
        .httpsCallable("getPaymentURL")
        .call(_getPaymentData(account, initialPaymenAmount));

    return (await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (context) {
            return CustomWebView(
              initialUrl: paymentUrl.data,
              title: "Update Card",
              onPageStarted: (url) {
                print("CustomWebView | PageStarted | URL === $url");
                if (url == _paymentCancelledUrl) {
                  Navigator.of(context).pop(false);
                } else if (url == _paymentSuccessfullUrl) {
                  Navigator.of(context).pop(true);
                }
              },
            );
          }),
        ) ??
        false);
  }

  dynamic _getPaymentData(Account account, double amount) => {
        "amount": amount,
        "name_first": account.firstName,
        "name_last": account.surname,
        "email_address": account.email,
        "cell_number": account.phoneNumber,
        "return_url": _paymentSuccessfullUrl,
        "cancel_url": _paymentCancelledUrl
      };

  void updateTokenPaymentCard(String token, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return CustomWebView(
          initialUrl: "https://www.payfast.co.za/eng/recurring/update/$token",
          title: "Update Card",
        );
      }),
    );
  }
}

class TokenPaymenResponse {
  final String status;
  final JsonObject paymentData;
  const TokenPaymenResponse(this.status, {this.paymentData = const {}});
}

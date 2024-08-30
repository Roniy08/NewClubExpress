//
//  ParameterConst.swift
//  ClubExpress
//
//  Created by Ronit Patel on 19/06/23.
//  Copyright © 2023 Zeta. All rights reserved.
//

import Foundation
struct readerConstants {
    static let connectM2Reader = "connect-m2-response"
    static let statusSuccess = "success"
    static let command = "command"
    static let statuserror = "error"
    static let status = "status"
    static let statusFailed = "failed"
    static let reader = "reader"
    static let cancel = "cancel"
    static let response = "response"
    static let error_code = "error_code"
    static let error_desc = "error_description"
    static let connectionLost = "connection-lost"
    static let updateCancelled = "UPDATE-CANCELLED"
    static let timeout = "TIMEOUT"
    static let bluetoothError = "bluetoothError"
    // Add more constants as needed
}
struct locationConstants
{
    static let checklocationService = "check-location-services"
    static let locationServiceResponse = "location-services-response"
    static let command = "command"
    static let isServiceEnabled = "location_services_enabled"
    static let isY = "Y"
    static let isN = "N"
}
struct locationConstantsCE
{
    static let locationServiceResponse = "send-coordinates"
    static let command = "command"
    static let isSuccess = "success"
    static let latitude = "latitude"
    static let longitude = "longitude"
}
struct ConnectNFCConstants
{
    static let ConnectNFCResponse = "connect-tap-to-pay-response"
    static let command = "command"
    static let statusStr = "status"
    static let statusSuccess = "success"
    static let statuserror = "error"
    static let statuFailed = "failed"
    static let statusCancel = "cancel"
}
struct paymentConstants
{
    static let command = "command"
    static let status = "action"
    static let statusStr = "status"
    static let statusSuccess = "success"
    static let statuserror = "error"
    static let statuFailed = "failed"
    static let statusCancel = "cancel"
    static let paymentIntentId = "payment_intent_id"
    static let paymentResponseJson = "response"
    static let paymentCancelled = "payment Cancelled"
    static let paymentResponse = "payment-sheet-response"
    static let error_code = "error_code"
    static let error_desc = "error_description"
    static let cancelPaymentResponse = "cancel-collect-payment-response"
    
}
struct NFCConstants
{
    static let command = "command"
    static let statusStr = "tap_to_pay_available"
    static let checkTapAndPayResponse = "tap-to-pay-support-response"
    
}
struct M2StateConstants
{
    static let command = "command"
    static let status = "status"
    static let statusSuccess = "success"
    static let getM2Response = "get-m2-stats-response"
    static let reader = "reader"
    static let readerBatterrLow = "20"    
}
struct disconnectTapandPayConstants
{
    static let command = "command"
    static let status = "status"
    static let disconnectTapandPayResponse = "disconnect-tap-to-pay-response"
}
struct M2EventConstants
{
    static let command = "command"
    static let event = "event"
    static let connectionLost = "connection-lost"
    static let readerLowBattery = "low-battery"
    static let readerbatteryUpdate = "battery-update"
    static let readerbatteryPer = "battery_percent"
    static let m2_event = "m2-event"
}
struct readerConstantsDisconnect {
    static let connectM2ReaderDisconnect = "disconnect-m2-response"
    static let statusSuccess = "success"
    static let command = "command"
    static let statuserror = "error"
    static let status = "status"
    // Add more constants as needed
}
// sdk version of stripe terminal
struct SDKConstants
{
    static let sdkVersion = "Stripe SDK: 3.0.0"
    static let testBuildVersion = "03"
    static let buildDate = "18"
}
struct LogEvent: CustomStringConvertible {
    enum Result: CustomStringConvertible {
        case started
        case succeeded
        case errored
        case message(String)

        var description: String {
            switch self {
            case .started: return "started"
            case .succeeded: return "succeeded"
            case .errored: return "errored"
            case .message(let string): return string
            }
        }
    }

    enum Method: String {
        case createPaymentIntent = "terminal.createPaymentIntent"
        case backendCreatePaymentIntent = "backend.createPaymentIntent"
        case collectPaymentMethod = "terminal.collectPaymentMethod"
        case cancelCollectPaymentMethod = "terminal.cancelCollectPaymentMethod"
        case readReusableCard = "terminal.readReusableCard"
        case cancelReadReusableCard = "terminal.cancelReadReusableCard"
        case retrievePaymentIntent = "terminal.retrievePaymentIntent"
        case processPayment = "terminal.processPayment"
        case capturePaymentIntent = "backend.capturePaymentIntent"
        case requestReaderInput = "delegate.didRequestReaderInput"
        case requestReaderDisplayMessage = "delegate.didRequestReaderDisplayMessage"
        case reportReaderEvent = "delegate.didReportReaderEvent"
        case reportUnexpectedReaderDisconnect = "delegate.didReportUnexpectedReaderDisconnect"
        case attachPaymentMethod = "backend.attachPaymentMethod"
        case collectRefundPaymentMethod = "terminal.collectRefundPaymentMethod"
        case cancelCollectRefundPaymentMethod = "terminal.cancelCollectRefundPaymentMethod"
        case processRefund = "terminal.processRefund"
        case setReaderDisplay = "terminal.setReaderDisplay"
        case clearReaderDisplay = "terminal.clearReaderDisplay"
        case createSetupIntent = "terminal.createSetupIntent"
        case collectSetupIntentPaymentMethod = "terminal.collectSetupIntentPaymentMethod"
        case cancelCollectSetupIntentPaymentMethod = "terminal.cancelCollectSetupIntentPaymentMethod"
        case confirmSetupIntent = "terminal.confirmSetupIntent"
        case backendCreateSetupIntent = "backend.createSetupIntent"
        case retrieveSetupIntent = "backend.retrieveSetupIntent"
        case captureSetupIntent = "backend.captuteSetupIntent"
        case cancelPaymentIntent = "terminal.cancelPaymentIntent"
        case cancelSetupIntent = "terminal.cancelSetupIntent"
    }

    enum AssociatedObject {
        case none
        case error(NSError)
        case json([String: AnyObject])
        case object(CustomStringConvertible)
    }

    let method: Method?
    var object: AssociatedObject = .none
    var result: Result = .started

    init(method: Method) {
        self.method = method
    }

    /// cell title
    var description: String {
        var string = ""
        guard let method = self.method else {
            return "Unknown"
        }
        switch method {
        case .requestReaderInput,
             .reportReaderEvent,
             .reportUnexpectedReaderDisconnect,
             .requestReaderDisplayMessage:
            return result.description
        case .createPaymentIntent, .backendCreatePaymentIntent:
            switch result {
            case .started: string = "Create PaymentIntent"
            case .succeeded: string = "Created PaymentIntent"
            case .errored: string = "Create PaymentIntent Failed"
            case .message(let message): string = message
            }
        case .collectPaymentMethod:
            switch result {
            case .started: string = "Collect PaymentMethod"
            case .succeeded: string = "Collected PaymentMethod"
            case .errored: string = "Collect PaymentMethod Failed"
            case .message(let message): string = message
            }
        case .processPayment:
            switch result {
            case .started: string = "Process Payment"
            case .succeeded: string = "Confirmed PaymentIntent"
            case .errored: string = "Confirm PaymentIntent Failed"
            case .message(let message): string = message
            }
        case .capturePaymentIntent:
            switch result {
            case .started: string = "Capture PaymentIntent"
            case .succeeded: string = "Captured PaymentIntent"
            case .errored: string = "Capture PaymentIntent Failed"
            case .message(let message): string = message
            }
        case .readReusableCard:
            switch result {
            case .started: string = "Read Reusable Card"
            case .succeeded: string = "Created Reusable Card"
            case .errored: string = "Read Reusable Card Failed"
            case .message(let message): string = message
            }
        case .retrievePaymentIntent:
            switch result {
            case .started: string = "Retrieve PaymentIntent"
            case .succeeded: string = "Retrieved PaymentIntent"
            case .errored: string = "Retrieve PaymentIntent Failed"
            case .message(let message): string = message
            }
        case .cancelCollectPaymentMethod:
            switch result {
            case .started: string = "Cancel Collect PaymentMethod"
            case .succeeded: string = "Canceled Collect PaymentMethod"
            case .errored: string = "Cancel Collect Payment Method Failed"
            case .message(let message): string = message
            }
        case .cancelReadReusableCard:
            switch result {
            case .started: string = "Cancel Read Reusable Card"
            case .succeeded: string = "Canceled Read Reusable Card"
            case .errored: string = "Cancel Read Reusable Card Failed"
            case .message(let message): string = message
            }
        case .attachPaymentMethod:
            switch result {
            case .started: string = "Attach PaymentMethod"
            case .succeeded: string = "Attached PaymentMethod"
            case .errored: string = "Attach PaymentMethod Failed"
            case .message(let message): string = message
            }
        case .collectRefundPaymentMethod:
            switch result {
            case .started: string = "Collect Refund PaymentMethod"
            case .succeeded: string = "Collected Refund PaymentMethod"
            case .errored: string = "Collect Refund PaymentMethod Failed"
            case .message(let message): string = message
            }
        case .processRefund:
            switch result {
            case .started: string = "Process Refund"
            case .succeeded: string = "Processed Refund"
            case .errored: string = "Process Refund Failed"
            case .message(let message): string = message
            }
        case .cancelCollectRefundPaymentMethod:
            switch result {
            case .started: string = "Cancel Collect Refund PaymentMethod"
            case .succeeded: string = "Canceled Collect Refund PaymentMethod"
            case .errored: string = "Cancel Collect Refund PaymentMethod Failed"
            case .message(let message): string = message
            }
        case .setReaderDisplay:
            switch result {
            case .started: string = "Setting Reader Display"
            case .succeeded: string = "Set Reader Display"
            case .errored: string = "Set Reader Display Failed"
            case .message(let message): string = message
            }
        case .clearReaderDisplay:
            switch result {
            case .started: string = "Clear Reader Display"
            case .succeeded: string = "Cleared Reader Display"
            case .errored: string = "Clear Reader Display Failed"
            case .message(let message): string = message
            }
        case .createSetupIntent, .backendCreateSetupIntent:
            switch result {
            case .started: string = "Create SetupIntent"
            case .succeeded: string = "Created SetupIntent"
            case .errored: string = "Create SetupIntent Failed"
            case .message(let message): string = message
            }
        case .cancelCollectSetupIntentPaymentMethod:
            switch result {
            case .started: string = "Cancel Collect SetupIntent PaymentMethod"
            case .succeeded: string = "Canceled Collect SetupIntent PaymentMethod"
            case .errored: string = "Cancel Collect SetupIntent PaymentMethod Failed"
            case .message(let message): string = message
            }
        case .collectSetupIntentPaymentMethod:
            switch result {
            case .started: string = "Collect SetupIntent PaymentMethod"
            case .succeeded: string = "Collected SetupIntent PaymentMethod"
            case .errored: string = "Collect SetupIntent PaymentMethod Failed"
            case .message(let message): string = message
            }
        case .confirmSetupIntent:
            switch result {
            case .started: string = "Confirm SetupIntent"
            case .succeeded: string = "Confirmed SetupIntent"
            case .errored: string = "Confirm SetupIntent Failed"
            case .message(let message): string = message
            }
        case .retrieveSetupIntent:
            switch result {
            case .started: string = "Retrieve SetupIntent"
            case .succeeded: string = "Retrieved SetupIntent"
            case .errored: string = "Retrieve SetupIntent Failed"
            case .message(let message): string = message
            }
        case .captureSetupIntent:
            switch result {
            case .started: string = "Capture SetupIntent"
            case .succeeded: string = "Captured SetupIntent"
            case .errored: string = "Capture SetupIntent Failed"
            case .message(let message): string = message
            }
        case .cancelPaymentIntent:
            switch result {
            case .started: string = "Cancel PaymentIntent"
            case .succeeded: string = "Canceled PaymentIntent"
            case .errored: string = "Cancel PaymentIntent Failed"
            case .message(let message): string = message
            }
        case .cancelSetupIntent:
            switch result {
            case .started: string = "Cancel SetupIntent"
            case .succeeded: string = "Canceled SetupIntent"
            case .errored: string = "Cancel SetupIntent Failed"
            case .message(let message): string = message
            }
        }
        return string
    }

//    var paymentIntentStatus: String? {
//        if case .paymentIntent(let intent) = object {
//            if intent.status == .requiresConfirmation {
//                return "requires_confirmation"
//            } else if intent.status == .requiresCapture {
//                return "requires_capture"
//            } else if let status = intent.originalJSON["status"] as? String {
//                return status
//            } else {
//                return "unknown"
//            }
//        }
//        return nil
//    }

}

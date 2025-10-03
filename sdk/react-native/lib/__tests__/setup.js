"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
/// <reference types="jest" />
const globals_1 = require("@jest/globals");
const mockGoMailerModule = {
    initialize: globals_1.jest.fn(() => __awaiter(void 0, void 0, void 0, function* () { })),
    getDeviceToken: globals_1.jest.fn(() => __awaiter(void 0, void 0, void 0, function* () { return ({ token: 'test-device-token' }); })),
    registerForPushNotifications: globals_1.jest.fn(() => __awaiter(void 0, void 0, void 0, function* () { })),
    setUser: globals_1.jest.fn(() => __awaiter(void 0, void 0, void 0, function* () { })),
    trackEvent: globals_1.jest.fn(() => __awaiter(void 0, void 0, void 0, function* () { })),
    addListener: globals_1.jest.fn(),
    removeAllListeners: globals_1.jest.fn(),
};
global.GoMailerModule = mockGoMailerModule;
global.mockGoMailerModule = mockGoMailerModule;
//# sourceMappingURL=setup.js.map
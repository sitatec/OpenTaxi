"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Pair = void 0;
class Pair {
    constructor(first, second) {
        this.first = first;
        this.second = second;
        this.toString = () => `${this.first} = ${this.second}`;
    }
}
exports.Pair = Pair;

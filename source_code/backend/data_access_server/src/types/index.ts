export type JSObject = Record<string, any>

export type Query = {
  text: string;
  paramValues: Array<number | string>;
}

export class Pair<T,K> {

  constructor(public first: T, public second: K) {}

  toString = () => `${this.first} = ${this.second}`;
}
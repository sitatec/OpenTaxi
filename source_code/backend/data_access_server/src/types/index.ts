export type JSObject = Record<string, any>

export type Query = {
  text: string;
  paramValues: Array<number | string>;
}

export type Pair<T,K> = {
  first: T
  second: K
}
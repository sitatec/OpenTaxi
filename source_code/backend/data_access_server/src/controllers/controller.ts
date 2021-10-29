import EntityManager from "../entity_manager";

export default class Controller {
  constructor(protected entityManager = new EntityManager()) {}
}
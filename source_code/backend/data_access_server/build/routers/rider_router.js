"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const rider_controller_1 = __importDefault(require("../controllers/rider_controller"));
const router = (0, express_1.Router)();
const riderController = new rider_controller_1.default();
const favoriteDriversRouter = (0, express_1.Router)();
// The `favoriteDriversRouter` must be added before other endpoints otherwise
// some routes like "rider/:id" will be resolved as "rider/favorite_drivers"
router.use("/favorite_drivers", favoriteDriversRouter);
router.post("/", riderController.createRider); // TODO add httpRequest data validation step.
router.get("/", riderController.getRider);
router.put("/:account_id", riderController.updateRider); // TODO add httpRequest data validation step.
router.delete("/:id", riderController.deleteRider);
favoriteDriversRouter.post("/", riderController.addFavoriteDriver);
favoriteDriversRouter.get("/", riderController.getFavoriteDrivers);
favoriteDriversRouter.delete("/", riderController.deleteFavoriteDriver);
exports.default = router;

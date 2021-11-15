import { Router } from "express";
import RiderController from "../controllers/rider_controller";
const router = Router();

const riderController = new RiderController();

const favoriteDriversRouter = Router();

// The `favoriteDriversRouter` must be added before other endpoints otherwise
// some routes like "rider/:id" will be resolved as "rider/favorite_drivers"
router.use("/favorite_drivers", favoriteDriversRouter);

router.post("/", riderController.createRider); // TODO add httpRequest data validation step.

router.get("/data", riderController.getRiderData);

router.get("/", riderController.getRider);

router.put("/:account_id", riderController.updateRider); // TODO add httpRequest data validation step.

router.delete("/:id", riderController.deleteRider);

favoriteDriversRouter.post("/", riderController.addFavoriteDriver);

favoriteDriversRouter.get("/", riderController.getFavoriteDrivers);

favoriteDriversRouter.delete("/", riderController.deleteFavoriteDriver);

export default router;

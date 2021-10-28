import { Router } from "express";
import {
  addFavoriteDriver,
  createRider,
  deleteFavoriteDriver,
  deleteRider,
  getFavoriteDrivers,
  getRider,
  updateRider,
} from "../controllers/rider_controller";

const router = Router();

const favoriteDriversRouter = Router();

// The `favoriteDriversRouter` must be added before other endpoints otherwise
// some routes like "rider/:id" will be resolved as "rider/favorite_drivers"
router.use("/favorite_drivers", favoriteDriversRouter);

router.post("/", createRider); // TODO add httpRequest data validation step.

router.get("/", getRider);

router.put("/:account_id", updateRider); // TODO add httpRequest data validation step.

router.delete("/:id", deleteRider);

favoriteDriversRouter.post("/", addFavoriteDriver);

favoriteDriversRouter.get("/", getFavoriteDrivers);

favoriteDriversRouter.delete("/", deleteFavoriteDriver);

export default router;

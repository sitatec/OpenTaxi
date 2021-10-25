import { Router } from "express";
import { createUser, deleteUser, getUser, updateUser } from "../controllers/user_controller";

const router = Router();

router.post("/", createUser);

router.get("/:id", getUser); 

router.put("/:id", updateUser);

router.delete("/:id", deleteUser);

const UserRouter = router
export default UserRouter;
import { Router } from "express";
import { createUser, getUser } from "../controllers/user_controller";

const router = Router();

router.post("/", createUser);

router.get("/:id", getUser); 

router.put("/:id", (req, res) => {

});

router.delete("/:id", (req, res) => {

});
const UserRouter = router
export default UserRouter;
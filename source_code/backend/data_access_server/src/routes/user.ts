import { Router } from "express";
import { createUser } from "../controllers/user_controller";

const router = Router();

router.post("/", createUser);

router.get("/:id", (req, res) => {

}); 

router.put("/:id", (req, res) => {

});

router.delete("/:id", (req, res) => {

});

export default router;
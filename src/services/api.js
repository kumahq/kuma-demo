import axios from "axios";

export default axios.create({
  baseURL: "https://jsonbox.io/box_6882679308111698016f",
  timeout: 5000,
  headers: {
    "Content-Type": "application/json"
  }
});

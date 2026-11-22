if (!process.env.MONGO_URL) {
  throw new Error("MONGO_URL environment variable is not set");
}

module.exports = {
  url: process.env.MONGO_URL
};
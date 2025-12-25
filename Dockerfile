FROM node:20
WORKDIR /app
COPY package.json package-lock.json* ./
RUN rm -rf node_modules
RUN npm install
COPY . .
RUN npm run build
EXPOSE 1337
CMD ["npm", "start"]   
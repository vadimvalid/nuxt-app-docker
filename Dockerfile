ARG NODE_VERSION=20.14.0

# Create build stage
FROM node:${NODE_VERSION}-slim as build

# Enable pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN npm install -g pnpm

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY ./package.json /app/
COPY ./pnpm-lock.yaml /app/

# Install dependencies
RUN pnpm install --shamefully-hoist

# Copy the rest of the application
COPY . ./

# Build the application
RUN pnpm run build

# Create production stage
FROM node:${NODE_VERSION}-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the output from the build stage to the working directory
COPY --from=build /app/.output ./

# Define environment variables
ENV HOST=0.0.0.0 NODE_ENV=production
ENV NODE_ENV=production

# Expose the port the application will run on
EXPOSE 3000

# Start the application
CMD ["node","/app/server/index.mjs"]
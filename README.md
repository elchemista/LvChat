# LvChat

**LvChat** is a real-time chat application built with Phoenix LiveView that matches users based on gender. In this implementation, the system connects individuals—typically pairing a man with a woman—using a matching engine based on Elixir’s GenServer and ETS for efficient in-memory operations. Users can also authenticate via Facebook OAuth2.

## Features

- **Real-time Chat:** Built with Phoenix LiveView for seamless live updates.
- **Dynamic Matching:** Matches users based on their gender, ensuring that a chat partner of the opposite gender is selected.
- **In-Memory Matching Engine:** Utilizes an ETS-backed GenServer for fast, concurrent matching.
- **Automatic Re-Matching:** If a chat partner disconnects, the system automatically searches for a new match.
- **Facebook OAuth2 Integration:** Provides an OAuth2 strategy for Facebook authentication to facilitate user login.

## Architecture Overview

### LvChat (Matching Server)
- **Purpose:** Implements the matching logic.
- **Key Functions:**
  - `match/2`: Filters a list of process IDs (PIDs) and returns a match for the opposite gender.
  - `subscribe/2` and `unsubscribe/1`: Manage the active connections by inserting or deleting entries from an ETS table.
  - Uses an ETS table (configured for high read and write concurrency) to store matching data.

### LvChatWeb.PageLive (LiveView Chat Interface)
- **Purpose:** Provides the real-time chat interface.
- **Lifecycle:**
  - **Mounting:** Loads the user profile (including gender) from the session and starts the matching process.
  - **Event Handling:** Processes new messages, resets the chat session, and handles logout events.
  - **Matching Process:** Continuously polls using a `:searching` message to find a chat partner and uses process monitoring to handle disconnects gracefully.
- **Message Handling:** Integrates real-time message sending and receiving, updating the UI with both user and partner messages.

### LvChatWeb.Facebook (OAuth2 Strategy for Facebook)
- **Purpose:** Provides integration with Facebook using OAuth2.
- **Key Functions:**
  - `client/0`: Configures the OAuth2 client using credentials from the application's environment.
  - `authorize_url!/1` and `get_token!/1`: Simplify generating authorization URLs and fetching tokens.
- **Integration:** Designed to be incorporated into your authentication flow to allow users to sign in with Facebook.

## Installation

### Prerequisites

- **Elixir:** Version 1.10+
- **Phoenix Framework:** Version 1.5+ (for LiveView support)
- **Node.js & npm:** For handling assets (if using Phoenix default asset setup)

### Steps

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/lv_chat.git
   cd lv_chat
   ```

2. **Fetch Dependencies:**

   ```bash
   mix deps.get
   ```

3. **Configure OAuth2 for Facebook:**

   Update your configuration (e.g., in `config/config.exs`):

   ```elixir
   config :lv_chat, :facebook,
     client_id: "YOUR_FACEBOOK_APP_ID",
     client_secret: "YOUR_FACEBOOK_APP_SECRET"
   ```

4. **Start the Application:**

   ```bash
   mix phx.server
   ```

5. **Open Your Browser:**

   Navigate to [http://localhost:4000](http://localhost:4000) to start chatting.

## Usage

1. **Authenticate:**
   - Use the Facebook OAuth2 integration to log in. The OAuth2 flow redirects you to Facebook for authentication and then back to the application.

2. **Real-time Matching:**
   - When a user logs in, the application reads your profile (including your gender) from the session.
   - You are automatically subscribed to the matching server. The server looks for another user with an opposite gender.
   - If a match is found, a handshake occurs between the two processes and a chat session is established.
   - If no match is found immediately, the system will continue to search every 5 seconds.

3. **Chatting:**
   - Send messages using the real-time interface. Your messages and the responses from your chat partner are handled live.
   - If your partner disconnects, the application resets the session and resumes searching for a new partner.

4. **Reset and Logout:**
   - Use the reset option to end the current session and initiate a new matching search.
   - Log out to exit the chat interface.

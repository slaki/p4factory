// Profiles control

// #define MULTICAST_DISABLE
// #define TUNNEL_DISABLE
// #define ACL_DISABLE

#ifdef MULTICAST_DISABLE
#define P4_MULTICAST_DISABLE
#endif

#ifdef TUNNEL_DISABLE
#define P4_TUNNEL_DISABLE
#endif

#ifdef ACL_DISABLE
#define P4_ACL_DISABLE
#endif

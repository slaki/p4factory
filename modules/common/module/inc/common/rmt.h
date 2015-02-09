/**
 * @file
 *
 * @brief Header file for high level interfaces to simulation core
 *
 */

#ifndef _RMT_RMT_H
#define _RMT_RMT_H

/* PLACEHOLDER */
typedef int bfm_port_t;

/**
 * @brief Initialize the forwarding simulation
 */

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initialize the Tofino model
 */
void rmt_init(void);

/**
 * @brief Inject a packet into the model.
 *
 * @param asic_id Which asic the packet is sent into
 * @param asic_port Which port on the asic the packet is sent into
 * @param buf Byte array containing the packet contents
 * @param len Length of the packet in bytes
 */
void
rmt_packet_receive(uint8_t asic_id, uint16_t asic_port, uint8_t *buf, int len);

/**
 * @brief Start packet processing in the model.
 */
void
rmt_start_packet_processing(void);

/**
 * @brief Stop packet processing in the model.
 */
void
rmt_stop_packet_processing(void);


typedef void (*RmtPacketCoordinatorTxFn)(int asic_id, int port, uint8_t *buf, int len);
/**
 * @brief Register a callback function which the model will use to "transmit"
 * a packet after the model has processed it and decided it should be sent out
 * a model port.
 *
 * @param tx_fn A pointer to the callback function.
 */
void
rmt_transmit_register(RmtPacketCoordinatorTxFn tx_fn);

/**
 * @brief Send a packet in for processing
 *
 * @param ingress The ingress port on which the packet was received
 * @param pkt Pointer to the packet data
 * @param len The number of bytes in the packet
 *
 * @return_val 0 Success
 * @return_val -1 Error
 */

//int rmt_process_pkt(bfm_port_t ingress, void *pkt, int len);

/**
 * @brief Update the log flags
 *
 * @param chip          The chip number
 * @param pipes         A mask of which pipes to update the flags in
 * @param stages        A mask of which stages to update the flags in
 * @param types         A mask of which types to update the flags for
 * @param rows_tabs     A mask of which rows/tables to update the flags in
 * @param cols          A mask of which columns to update the flags in
 * @param or_log_flags  This value is or with the flags
 * @param and_log_flags This value is anded with the flags
 */
void
rmt_update_log_flags(int chip, uint64_t pipes, uint64_t stages, 
                     uint64_t types, uint64_t rows_tabs, uint64_t cols,
                     uint64_t or_log_flags, uint64_t and_log_flags);

/**
 * @brief Typedef of logging vector
 *
 * Just looks like printf
 */

typedef int (*bfm_logging_f)(char *format, ...);

/**
 * @brief Set the logging vector
 *
 * @param log_fn The logging vector; set to NULL to disable logging
 */

extern void rmt_logger_set(bfm_logging_f log_fn);

/**
 * @brief Enumeration of logging levels understood by sim
 *
 * Simple linear levels
 */
typedef enum bfm_log_level_e {
    BFM_LOG_LEVEL_NONE,      /** No output */
    BFM_LOG_LEVEL_FATAL,     /** Only fatal errors */
    BFM_LOG_LEVEL_ERROR,     /** Errors */
    BFM_LOG_LEVEL_WARN,      /** Warnings */
    BFM_LOG_LEVEL_INFO,      /** Informational */
    BFM_LOG_LEVEL_VERBOSE,   /** Verbose */
    BFM_LOG_LEVEL_TRACE,     /** Most fn calls */
} bfm_log_level_t;

/**
 * @brief Set the log level for the forwarding code
 *
 * @param level The log level
 */
extern void rmt_log_level_set(bfm_log_level_t level);


/*
 * Other APIs we expect to need for the simulation
 *
 * Set up the multicast tables
 * Queue configuration
 */

#ifdef __cplusplus
}
#endif

#endif

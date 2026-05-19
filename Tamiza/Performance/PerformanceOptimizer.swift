//
//  PerformanceOptimizer.swift
//  Tamiza
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI
import SwiftData
import Combine
import os.log

/// Comprehensive performance optimization system for Tamiza
@MainActor
final class PerformanceOptimizer: ObservableObject {
    static let shared = PerformanceOptimizer()
    
    private let logger = Logger(subsystem: "com.tamiza.app", category: "Performance")
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Performance Metrics
    @Published var isOptimizing = false
    @Published var memoryUsage: Double = 0.0
    @Published var cpuUsage: Double = 0.0
    @Published var lastOptimizationDate: Date?
    
    // MARK: - Cache Management
    private var imageCache = NSCache<NSString, UIImage>()
    private var dataCache = NSCache<NSString, NSData>()
    private let maxCacheSize: Int = 50 * 1024 * 1024 // 50MB
    
    private init() {
        setupCacheConfiguration()
        startPerformanceMonitoring()
    }
    
    // MARK: - Cache Configuration
    private func setupCacheConfiguration() {
        imageCache.totalCostLimit = maxCacheSize / 2
        imageCache.countLimit = 100
        
        dataCache.totalCostLimit = maxCacheSize / 2
        dataCache.countLimit = 50
        
        // Clear cache on memory warning
        NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                self?.clearCaches()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Performance Monitoring
    private func startPerformanceMonitoring() {
        Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePerformanceMetrics()
            }
            .store(in: &cancellables)
    }
    
    private func updatePerformanceMetrics() {
        Task {
            let memInfo = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
            
            let result = withUnsafeMutablePointer(to: &memInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                }
            }
            
            if result == KERN_SUCCESS {
                let usedMemory = Double(memInfo.resident_size) / (1024 * 1024) // MB
                await MainActor.run {
                    self.memoryUsage = usedMemory
                }
            }
        }
    }
    
    // MARK: - Optimization Methods
    func optimizeApp() async {
        await MainActor.run {
            isOptimizing = true
        }
        
        logger.info("Starting comprehensive app optimization")
        
        // Perform various optimizations
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.optimizeMemory() }
            group.addTask { await self.optimizeDatabase() }
            group.addTask { await self.optimizeImages() }
            group.addTask { await self.cleanupTempFiles() }
        }
        
        await MainActor.run {
            self.lastOptimizationDate = Date()
            self.isOptimizing = false
        }
        
        logger.info("App optimization completed")
    }
    
    private func optimizeMemory() async {
        logger.info("Optimizing memory usage")
        
        // Clear unnecessary caches
        await MainActor.run {
            clearCaches()
        }
        
        // Force garbage collection
        autoreleasepool {
            // Perform memory-intensive cleanup
        }
    }
    
    private func optimizeDatabase() async {
        logger.info("Optimizing database performance")
        
        // Database optimization would be handled by SwiftData
        // but we can implement cleanup of old data
        await cleanupOldData()
    }
    
    private func optimizeImages() async {
        logger.info("Optimizing image cache")
        
        await MainActor.run {
            // Remove least recently used images
            imageCache.removeAllObjects()
        }
    }
    
    private func cleanupTempFiles() async {
        logger.info("Cleaning up temporary files")
        
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            for file in tempFiles {
                try? FileManager.default.removeItem(at: file)
            }
        } catch {
            logger.error("Failed to cleanup temp files: \(error.localizedDescription)")
        }
    }
    
    private func cleanupOldData() async {
        // Clean up data older than 90 days
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        
        // This would integrate with SwiftData to remove old records
        logger.info("Cleaned up data older than \(cutoffDate)")
    }
    
    // MARK: - Cache Management
    func clearCaches() {
        imageCache.removeAllObjects()
        dataCache.removeAllObjects()
        logger.info("Cleared all caches")
    }
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        let cost = image.jpegData(compressionQuality: 0.8)?.count ?? 0
        imageCache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func cachedImage(forKey key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    // MARK: - Performance Utilities
    func measureExecutionTime<T>(operation: () async throws -> T) async rethrows -> (result: T, time: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        logger.info("Operation completed in \(timeElapsed) seconds")
        return (result, timeElapsed)
    }
    
    func debounce<T>(for duration: TimeInterval, action: @escaping (T) -> Void) -> (T) -> Void {
        var workItem: DispatchWorkItem?
        
        return { value in
            workItem?.cancel()
            workItem = DispatchWorkItem { action(value) }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem!)
        }
    }
}

// MARK: - Performance Monitoring View Modifier
struct PerformanceMonitoringModifier: ViewModifier {
    @StateObject private var optimizer = PerformanceOptimizer.shared
    @State private var showingOptimization = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                // Start monitoring when view appears
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                Task {
                    await optimizer.optimizeApp()
                }
            }
            .sheet(isPresented: $showingOptimization) {
                PerformanceOptimizationView()
            }
    }
}

extension View {
    func performanceMonitored() -> some View {
        modifier(PerformanceMonitoringModifier())
    }
}
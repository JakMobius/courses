#include <vulkan/vulkan.h>
#include <GLFW/glfw3.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <pthread.h>

#define WIDTH 600
#define HEIGHT 700

GLFWwindow* window;
VkInstance instance;
VkSurfaceKHR surface;
VkPhysicalDevice physicalDevice = VK_NULL_HANDLE;
VkDevice device;
VkQueue graphicsQueue;
VkSwapchainKHR swapChain;
VkImageView* swapChainImageViews;
VkCommandPool commandPool;
VkCommandBuffer* commandBuffers;
VkSemaphore imageAvailableSemaphore;
VkSemaphore renderFinishedSemaphore;

VkDeviceMemory stagingMemory;
VkBuffer stagingBuffer;

void* mappedBuffer = NULL;

void initWindow() {
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    window = glfwCreateWindow(WIDTH, HEIGHT, "Vulkan Window", NULL, NULL);
}

uint32_t findMemoryType(uint32_t typeFilter, VkMemoryPropertyFlags properties) {
    VkPhysicalDeviceMemoryProperties memProperties;
    vkGetPhysicalDeviceMemoryProperties(physicalDevice, &memProperties);

    for (uint32_t i = 0; i < memProperties.memoryTypeCount; i++) {
        if ((typeFilter & (1 << i)) && (memProperties.memoryTypes[i].propertyFlags & properties) == properties) {
            return i;
        }
    }

    printf("Failed to find suitable memory type!\n");
    exit(1);
}

void initVulkan() {
    // Create Vulkan instance
    VkApplicationInfo appInfo = {};
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "Hello Vulkan";
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName = "No Engine";
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion = VK_API_VERSION_1_0;

    uint32_t glfwExtensionCount = 0;
    const char** glfwExtensions = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

    VkInstanceCreateInfo createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;
    createInfo.enabledExtensionCount = glfwExtensionCount;
    createInfo.ppEnabledExtensionNames = glfwExtensions;

    if (vkCreateInstance(&createInfo, NULL, &instance) != VK_SUCCESS) {
        printf("Failed to create instance!\n");
        exit(1);
    }

    // Create surface
    if (glfwCreateWindowSurface(instance, window, NULL, &surface) != VK_SUCCESS) {
        printf("Failed to create window surface!\n");
        exit(1);
    }

    // Pick physical device
    uint32_t deviceCount = 0;
    vkEnumeratePhysicalDevices(instance, &deviceCount, NULL);
    if (deviceCount == 0) {
        printf("Failed to find GPUs with Vulkan support!\n");
        exit(1);
    }
    VkPhysicalDevice devices[deviceCount];
    vkEnumeratePhysicalDevices(instance, &deviceCount, devices);
    physicalDevice = devices[0];

    // Create logical device
    VkDeviceQueueCreateInfo queueCreateInfo = {};
    queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    queueCreateInfo.queueFamilyIndex = 0;
    queueCreateInfo.queueCount = 1;
    float queuePriority = 1.0f;
    queueCreateInfo.pQueuePriorities = &queuePriority;

    const char* deviceExtensions[] = {VK_KHR_SWAPCHAIN_EXTENSION_NAME};

    VkDeviceCreateInfo deviceCreateInfo = {};
    deviceCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    deviceCreateInfo.queueCreateInfoCount = 1;
    deviceCreateInfo.pQueueCreateInfos = &queueCreateInfo;
    deviceCreateInfo.enabledExtensionCount = 1;
    deviceCreateInfo.ppEnabledExtensionNames = deviceExtensions;

    if (vkCreateDevice(physicalDevice, &deviceCreateInfo, NULL, &device) != VK_SUCCESS) {
        printf("Failed to create logical device!\n");
        exit(1);
    }

    vkGetDeviceQueue(device, 0, 0, &graphicsQueue);

    // Create swap chain
    VkSwapchainCreateInfoKHR swapChainCreateInfo = {};
    swapChainCreateInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
    swapChainCreateInfo.surface = surface;
    swapChainCreateInfo.minImageCount = 2;
    swapChainCreateInfo.imageFormat = VK_FORMAT_B8G8R8A8_SRGB;
    swapChainCreateInfo.imageColorSpace = VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;
    swapChainCreateInfo.imageExtent.width = WIDTH;
    swapChainCreateInfo.imageExtent.height = HEIGHT;
    swapChainCreateInfo.imageArrayLayers = 1;
    swapChainCreateInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT;
    swapChainCreateInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE;
    swapChainCreateInfo.preTransform = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
    swapChainCreateInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
    swapChainCreateInfo.presentMode = VK_PRESENT_MODE_FIFO_KHR;
    swapChainCreateInfo.clipped = VK_TRUE;

    if (vkCreateSwapchainKHR(device, &swapChainCreateInfo, NULL, &swapChain) != VK_SUCCESS) {
        printf("Failed to create swap chain!\n");
        exit(1);
    }

    // Create image views
    uint32_t imageCount = 0;
    vkGetSwapchainImagesKHR(device, swapChain, &imageCount, NULL);
    VkImage swapChainImages[imageCount] = {};
    vkGetSwapchainImagesKHR(device, swapChain, &imageCount, swapChainImages);

    swapChainImageViews = malloc(imageCount * sizeof(VkImageView));
    for (uint32_t i = 0; i < imageCount; i++) {
        VkImageViewCreateInfo createInfo = {};
        createInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        createInfo.image = swapChainImages[i];
        createInfo.viewType = VK_IMAGE_VIEW_TYPE_2D;
        createInfo.format = VK_FORMAT_B8G8R8A8_SRGB;
        createInfo.components.r = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.g = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.b = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.a = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        createInfo.subresourceRange.baseMipLevel = 0;
        createInfo.subresourceRange.levelCount = 1;
        createInfo.subresourceRange.baseArrayLayer = 0;
        createInfo.subresourceRange.layerCount = 1;

        if (vkCreateImageView(device, &createInfo, NULL, &swapChainImageViews[i]) != VK_SUCCESS) {
            printf("Failed to create image views!\n");
            exit(1);
        }
    }

    VkMemoryAllocateInfo memAllocInfo = {};
    memAllocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;    
    memAllocInfo.allocationSize = WIDTH * HEIGHT * 4;
    memAllocInfo.memoryTypeIndex = findMemoryType(-1, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);

    if (vkAllocateMemory(device, &memAllocInfo, NULL, &stagingMemory) != VK_SUCCESS) {
        printf("Failed to allocate staging buffer memory!\n");
        exit(1);
    }   

    // Create stagingBuffer
    VkBufferCreateInfo bufferInfo = {};
    bufferInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
    bufferInfo.size = WIDTH * HEIGHT * 4;
    bufferInfo.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
    bufferInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;

    if (vkCreateBuffer(device, &bufferInfo, NULL, &stagingBuffer) != VK_SUCCESS) {
        printf("Failed to create buffer!\n");
        exit(1);
    }

    vkBindBufferMemory(device, stagingBuffer, stagingMemory, 0);
    
    // Map the buffer to the memory and write something to it
    vkMapMemory(device, stagingMemory, 0, WIDTH * HEIGHT * 4, 0, &mappedBuffer);
    printf("mappedBuffer = 0x%llx\n", (uint64_t)mappedBuffer);

    // Create command pool
    VkCommandPoolCreateInfo poolInfo = {};
    poolInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
    poolInfo.queueFamilyIndex = 0;

    if (vkCreateCommandPool(device, &poolInfo, NULL, &commandPool) != VK_SUCCESS) {
        printf("Failed to create command pool!\n");
        exit(1);
    }

    // Create command buffers
    commandBuffers = malloc(imageCount * sizeof(VkCommandBuffer));
    VkCommandBufferAllocateInfo commandBufferAllocInfo = {};
    commandBufferAllocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    commandBufferAllocInfo.commandPool = commandPool;
    commandBufferAllocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    commandBufferAllocInfo.commandBufferCount = imageCount;

    if (vkAllocateCommandBuffers(device, &commandBufferAllocInfo, commandBuffers) != VK_SUCCESS) {
        printf("Failed to allocate command buffers!\n");
        exit(1);
    }

    // Record command buffers
    for (uint32_t i = 0; i < imageCount; i++) {
        VkCommandBufferBeginInfo beginInfo = {};
        beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;

        if (vkBeginCommandBuffer(commandBuffers[i], &beginInfo) != VK_SUCCESS) {
            printf("Failed to begin recording command buffer!\n");
            exit(1);
        }

        // Make the swapchain image ready for write
        VkImageMemoryBarrier swapchainInitBarrier = {};
        swapchainInitBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        swapchainInitBarrier.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        swapchainInitBarrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        swapchainInitBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        swapchainInitBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        swapchainInitBarrier.image = swapChainImages[i];
        swapchainInitBarrier.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        swapchainInitBarrier.subresourceRange.baseMipLevel = 0;
        swapchainInitBarrier.subresourceRange.levelCount = 1;
        swapchainInitBarrier.subresourceRange.baseArrayLayer = 0;
        swapchainInitBarrier.subresourceRange.layerCount = 1;
        swapchainInitBarrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        swapchainInitBarrier.dstAccessMask = 0;

        vkCmdPipelineBarrier(commandBuffers[i], VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, NULL, 0, NULL, 1, &swapchainInitBarrier);

        // Copy bytes from staging buffer to texture image
        VkImageSubresourceLayers subResource = {};
        subResource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        subResource.baseArrayLayer = 0;
        subResource.mipLevel = 0;
        subResource.layerCount = 1;
    
        VkBufferImageCopy region = {};
        region.bufferOffset = 0;
        region.bufferRowLength = 0;
        region.bufferImageHeight = 0;
        region.imageSubresource = subResource;
        region.imageOffset = (VkOffset3D) {0, 0, 0};
        region.imageExtent = (VkExtent3D) {WIDTH, HEIGHT, 1};

        vkCmdCopyBufferToImage(commandBuffers[i], stagingBuffer, swapChainImages[i], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &region);

        // Make the swapchain image ready for presentation
        VkImageMemoryBarrier presentBarrier = {};
        presentBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        presentBarrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        presentBarrier.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
        presentBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        presentBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
        presentBarrier.image = swapChainImages[i];
        presentBarrier.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        presentBarrier.subresourceRange.baseMipLevel = 0;
        presentBarrier.subresourceRange.levelCount = 1;
        presentBarrier.subresourceRange.baseArrayLayer = 0;
        presentBarrier.subresourceRange.layerCount = 1;
        presentBarrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        presentBarrier.dstAccessMask = 0;

        vkCmdPipelineBarrier(commandBuffers[i], VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, NULL, 0, NULL, 1, &presentBarrier);

        if (vkEndCommandBuffer(commandBuffers[i]) != VK_SUCCESS) {
            printf("Failed to record command buffer!\n");
            exit(1);
        }
    }

    // Create semaphores
    VkSemaphoreCreateInfo semaphoreInfo = {};
    semaphoreInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;

    if (vkCreateSemaphore(device, &semaphoreInfo, NULL, &imageAvailableSemaphore) != VK_SUCCESS ||
        vkCreateSemaphore(device, &semaphoreInfo, NULL, &renderFinishedSemaphore) != VK_SUCCESS) {
        printf("Failed to create semaphores!\n");
        exit(1);
    }
}

void drawFrame() {
    // Flush the memory
    VkMappedMemoryRange mappedRange = {};
    mappedRange.sType = VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE;
    mappedRange.memory = stagingMemory;
    mappedRange.offset = 0;
    mappedRange.size = VK_WHOLE_SIZE;
    vkFlushMappedMemoryRanges(device, 1, &mappedRange);

    uint32_t imageIndex = 0;
    vkAcquireNextImageKHR(device, swapChain, UINT64_MAX, imageAvailableSemaphore, VK_NULL_HANDLE, &imageIndex);

    VkSubmitInfo submitInfo = {};
    submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;

    VkSemaphore waitSemaphores[] = {imageAvailableSemaphore};
    VkPipelineStageFlags waitStages[] = {VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT};
    submitInfo.waitSemaphoreCount = 1;
    submitInfo.pWaitSemaphores = waitSemaphores;
    submitInfo.pWaitDstStageMask = waitStages;

    submitInfo.commandBufferCount = 1;
    submitInfo.pCommandBuffers = &commandBuffers[imageIndex];

    VkSemaphore signalSemaphores[] = {renderFinishedSemaphore};
    submitInfo.signalSemaphoreCount = 1;
    submitInfo.pSignalSemaphores = signalSemaphores;

    if (vkQueueSubmit(graphicsQueue, 1, &submitInfo, VK_NULL_HANDLE) != VK_SUCCESS) {
        printf("Failed to submit draw command buffer!\n");
        exit(1);
    }
    
    vkQueueWaitIdle(graphicsQueue);

    VkPresentInfoKHR presentInfo = {};
    presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;

    presentInfo.waitSemaphoreCount = 1;
    presentInfo.pWaitSemaphores = signalSemaphores;

    VkSwapchainKHR swapChains[] = {swapChain};
    presentInfo.swapchainCount = 1;
    presentInfo.pSwapchains = swapChains;
    presentInfo.pImageIndices = &imageIndex;

    vkQueuePresentKHR(graphicsQueue, &presentInfo);
}

void mainLoop() {
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        drawFrame();
    }

    vkDeviceWaitIdle(device);
}

void cleanup() {
    vkUnmapMemory(device, stagingMemory);
    vkDestroyBuffer(device, stagingBuffer, NULL);
    vkFreeMemory(device, stagingMemory, NULL);
    vkDestroySemaphore(device, renderFinishedSemaphore, NULL);
    vkDestroySemaphore(device, imageAvailableSemaphore, NULL);
    vkDestroyCommandPool(device, commandPool, NULL);
    for (uint32_t i = 0; i < 2; i++) {
        vkDestroyImageView(device, swapChainImageViews[i], NULL);
    }
    vkDestroySwapchainKHR(device, swapChain, NULL);
    vkDestroyDevice(device, NULL);
    vkDestroySurfaceKHR(instance, surface, NULL);
    vkDestroyInstance(instance, NULL);
    glfwDestroyWindow(window);
    glfwTerminate();
}

void* imageMain(void* arg);
void* sortMain(void* arg);
void* fibMain(void* arg);
void* threadMain(void* arg);

void createThread() {
    pthread_t thread = 0;
    pthread_attr_t tattr = {};

    uint64_t stackPtr = (uint64_t) mappedBuffer;
    uint64_t stackSize = WIDTH * HEIGHT * 4;

    uint64_t ptrAlign = 8;
    uint64_t sizeAlign = getpagesize();

    int res = 0;

    if(stackPtr % ptrAlign) {
        stackSize -= (ptrAlign - stackPtr % ptrAlign);
        stackPtr += (ptrAlign - stackPtr % ptrAlign);
    }
    stackSize -= stackSize % sizeAlign;

    printf("Stack: ptr = 0x%llx, size = 0x%llx\n", stackPtr, stackSize);

    if((res = pthread_attr_init(&tattr)) != 0) {
        fprintf(stderr, "pthread_attr_init: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }

    if((res = pthread_attr_setstack(&tattr, (void*)stackPtr, stackSize)) != 0) {
        fprintf(stderr, "pthread_attr_setstack: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }

    if((res = pthread_create(&thread, &tattr, threadMain, mappedBuffer)) != 0) {
        fprintf(stderr, "pthread_create: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }

    if((res = pthread_attr_destroy(&tattr)) != 0) {
        fprintf(stderr, "pthread_attr_destroy: %s\n", strerror(res));
        exit(EXIT_FAILURE);
    }
}

int main() {
    initWindow();
    initVulkan();
    createThread();
    mainLoop();
    cleanup();
    return 0;
}

void* threadMain(void* arg) {
    return fibMain(arg);
    // return sortMain(arg);
    // return imageMain(arg);
}
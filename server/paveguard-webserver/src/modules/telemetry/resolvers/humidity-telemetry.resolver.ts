import { Resolver, Query, Args, Mutation } from '@nestjs/graphql';
import { TemperatureTelemetryQuery } from '../models/temperature-telemetry.model';
import { CreateHumidityTelemetryDto } from '../dto/create-humidity-telemetry.dto';
import { HumidityTelemetryService } from '../service/humidity-telemetry/humidity-telemetry.service';
import { HumidityTelemetryQuery } from '../models/humidity-telemetry.model';

@Resolver(() => HumidityTelemetryQuery)
export class HumidityTelemetryResolver {
  constructor(
    private readonly humidityTelemetryService: HumidityTelemetryService
  ) {}

  @Query(() => [HumidityTelemetryQuery])
  async humidityTelemetries() {
    return this.humidityTelemetryService.findAll();
  }

  @Mutation(() => HumidityTelemetryQuery)
  async createHumidityTelemetry(
    @Args('input') input: CreateHumidityTelemetryDto,
  ) {
    return this.humidityTelemetryService.create(input);
  }
}

import { Resolver, Query, Args, Mutation, Field, ObjectType } from '@nestjs/graphql';
import { CreateHumidityTelemetryDto } from '../dto/create-humidity-telemetry.dto';
import { HumidityTelemetryService } from '../services/humidity-telemetry/humidity-telemetry.service';
import { TelemetryQuery } from './telemetry.resolver';


@ObjectType()
export class HumidityTelemetryQuery extends TelemetryQuery {

  @Field()
  humidity: number;
}

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
    @Args() input: CreateHumidityTelemetryDto,
  ) {
    return this.humidityTelemetryService.create(input);
  }
}

